#ifdef QT_CORE_LIB
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>
#include <QQuickWindow>
#include <QTimer>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include "ShrinkItEngine.h"

int main(int argc, char* argv[]) {
    QGuiApplication::setApplicationName("ShrinkIt");
    QGuiApplication::setApplicationVersion("1.0.0");
    QGuiApplication::setOrganizationName("ShrinkIt");
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    bool recordMode = false;
    QString outDir = "images";
    for (int i = 1; i < argc; ++i) {
        if (QString(argv[i]) == "--record-demo") {
            recordMode = true;
            if (i + 1 < argc) outDir = argv[i + 1];
            break;
        }
    }

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/ui/assets/app_icon.png"));

    // Use Qt's Basic style
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine qmlEngine;

    // Create engine backend and register as a global context property
    auto* shrinkEngine = new shrinkit::qt_bridge::ShrinkItEngine(&app);
    qmlEngine.rootContext()->setContextProperty("ShrinkItEngine", shrinkEngine);

    qmlEngine.addImportPath("qrc:/");
    qmlEngine.addImportPath("qrc:/ui/qml");

    const QUrl url(QStringLiteral("qrc:/ui/qml/Main.qml"));
    qmlEngine.load(url);

    if (qmlEngine.rootObjects().isEmpty()) {
        qWarning("ShrinkIt: Failed to load main QML root window.");
        return -1;
    }

    auto* window = qobject_cast<QQuickWindow*>(qmlEngine.rootObjects().first());

    if (recordMode && window) {
        QDir().mkpath(outDir + "/frames");

        // Prepare demo test file
        QString demoInput = QDir::tempPath() + "/shrinkit_demo.txt";
        QString demoOutput = demoInput + ".huff";
        QString demoRestored = QDir::tempPath() + "/restored_shrinkit_demo.txt";

        {
            QFile f(demoInput);
            if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
                QTextStream ts(&f);
                ts << "=== ShrinkIt Lossless Huffman & LZ77 Compression Demo ===\n";
                for (int i = 0; i < 300; ++i) {
                    ts << "Timestamp: 2026-11-18T12:00:00Z | Channel: " << (i % 8)
                       << " | Status: OK | Payload: REPEAT_TOKEN_DATA_STREAM_PACKET_" << (i % 16) << "\n";
                }
            }
        }

        auto* timer = new QTimer(&app);
        auto* frameCount = new int(0);

        QObject::connect(timer, &QTimer::timeout, [=]() {
            (*frameCount)++;
            int fc = *frameCount;

            // Phase 1: Overview View (0 - 45)
            if (fc == 1) {
                window->setProperty("currentPage", 0);
            } else if (fc == 35) {
                QImage img = window->grabWindow();
                img.save(outDir + "/overview_screen.png");
            }
            // Phase 2: Switch to Compress View (46 - 95)
            else if (fc == 46) {
                window->setProperty("currentPage", 1);
            } else if (fc == 52) {
                if (auto* cView = window->findChild<QObject*>("compressView")) {
                    QMetaObject::invokeMethod(cView, "setInputFile", Q_ARG(QVariant, demoInput));
                }
            } else if (fc == 58) {
                shrinkEngine->compressFile(demoInput, demoOutput);
            } else if (fc == 88) {
                QImage img = window->grabWindow();
                img.save(outDir + "/compress_screen.png");
            }
            // Phase 3: Switch to Decompress View (96 - 150)
            else if (fc == 96) {
                window->setProperty("currentPage", 2);
            } else if (fc == 102) {
                if (auto* dView = window->findChild<QObject*>("decompressView")) {
                    QMetaObject::invokeMethod(dView, "setInputArchive", Q_ARG(QVariant, demoOutput));
                }
            } else if (fc == 108) {
                shrinkEngine->decompressFile(demoOutput, demoRestored);
            } else if (fc == 140) {
                QImage img = window->grabWindow();
                img.save(outDir + "/decompress_screen.png");
            }

            // Save frame for smooth 30fps animation
            if (fc <= 150) {
                QImage frame = window->grabWindow();
                QString framePath = QString("%1/frames/frame_%2.png").arg(outDir).arg(fc, 4, 10, QChar('0'));
                frame.save(framePath);
            } else {
                timer->stop();
                QCoreApplication::quit();
            }
        });

        timer->start(33); // ~30 FPS
    }

    return app.exec();
}
#else
int main_qt_placeholder = 0;
#endif
