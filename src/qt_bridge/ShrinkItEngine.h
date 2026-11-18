#pragma once

#ifdef QT_CORE_LIB
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QThread>
#include <QUrl>
#include <memory>

#include "CompressionWorker.h"
#include "HuffmanCompressor.h"

namespace shrinkit {
namespace qt_bridge {

/**
 * @brief Primary QML-exposed engine for the ShrinkIt application.
 *
 * Registered as a singleton QML type: `ShrinkItEngine`.
 * All heavy work is dispatched to a background QThread.
 * QML binds to properties and signals declaratively.
 */
class ShrinkItEngine : public QObject {
    Q_OBJECT

    // Core operational state exposed to QML
    Q_PROPERTY(bool isBusy READ isBusy NOTIFY isBusyChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString progressStage READ progressStage NOTIFY progressChanged)
    Q_PROPERTY(QString lastError READ lastError NOTIFY errorOccurred)
    Q_PROPERTY(QVariantMap lastStats READ lastStats NOTIFY statsReady)
    Q_PROPERTY(QString lastOutputPath READ lastOutputPath NOTIFY operationComplete)

    // Glass design system runtime configuration
    Q_PROPERTY(double glassOpacity READ glassOpacity WRITE setGlassOpacity NOTIFY glassConfigChanged)
    Q_PROPERTY(double glassBlur READ glassBlur WRITE setGlassBlur NOTIFY glassConfigChanged)
    Q_PROPERTY(double glassFrost READ glassFrost WRITE setGlassFrost NOTIFY glassConfigChanged)
    Q_PROPERTY(double glassIOR READ glassIOR WRITE setGlassIOR NOTIFY glassConfigChanged)
    Q_PROPERTY(double glassThickness READ glassThickness WRITE setGlassThickness NOTIFY glassConfigChanged)
    Q_PROPERTY(double glassBevel READ glassBevel WRITE setGlassBevel NOTIFY glassConfigChanged)
    Q_PROPERTY(double glassDispersion READ glassDispersion WRITE setGlassDispersion NOTIFY glassConfigChanged)
    Q_PROPERTY(double glassMergeDistance READ glassMergeDistance WRITE setGlassMergeDistance NOTIFY glassConfigChanged)

public:
    explicit ShrinkItEngine(QObject* parent = nullptr);
    ~ShrinkItEngine() override;

    // --- Readable Properties ---
    bool isBusy() const noexcept { return isBusy_; }
    double progress() const noexcept { return progress_; }
    QString progressStage() const noexcept { return progressStage_; }
    QString lastError() const noexcept { return lastError_; }
    QVariantMap lastStats() const noexcept { return lastStats_; }
    QString lastOutputPath() const noexcept { return lastOutputPath_; }

    double glassOpacity() const noexcept { return glassOpacity_; }
    double glassBlur() const noexcept { return glassBlur_; }
    double glassFrost() const noexcept { return glassFrost_; }
    double glassIOR() const noexcept { return glassIOR_; }
    double glassThickness() const noexcept { return glassThickness_; }
    double glassBevel() const noexcept { return glassBevel_; }
    double glassDispersion() const noexcept { return glassDispersion_; }
    double glassMergeDistance() const noexcept { return glassMergeDistance_; }

    // --- Writable Glass Config ---
    void setGlassOpacity(double v);
    void setGlassBlur(double v);
    void setGlassFrost(double v);
    void setGlassIOR(double v);
    void setGlassThickness(double v);
    void setGlassBevel(double v);
    void setGlassDispersion(double v);
    void setGlassMergeDistance(double v);

public slots:
    // Called from QML
    void compressFile(const QString& inputPath, const QString& outputPath);
    void decompressFile(const QString& inputPath, const QString& outputPath);
    void analyzeFile(const QString& inputPath);
    void inspectFile(const QString& filePath);
    void cancelOperation();
    void resetGlassDefaults();

    // Utility helpers callable from QML
    Q_INVOKABLE QString formatBytes(qint64 bytes) const;
    Q_INVOKABLE qint64 getFileSize(const QString& path) const;
    Q_INVOKABLE bool captureWindow(QObject* window, const QString& filePath);
    Q_INVOKABLE QString cleanFilePath(const QUrl& fileUrl) const;
    Q_INVOKABLE QString generateDefaultOutputPath(const QString& inputPath, bool compress) const;
    Q_INVOKABLE bool fileExists(const QString& path) const;
    Q_INVOKABLE QString appVersion() const { return QStringLiteral("1.0.0"); }

signals:
    void isBusyChanged();
    void progressChanged();
    void statsReady();
    void operationComplete(bool success, const QString& message);
    void errorOccurred();
    void glassConfigChanged();

private slots:
    void onWorkerProgress(double progress, const QString& stage);
    void onCompressionFinished(const QVariantMap& stats);
    void onDecompressionFinished(bool success, const QString& outputPath);
    void onAnalysisFinished(const QVariantMap& stats);
    void onWorkerError(const QString& errorMessage);

private:
    void startWorkerThread(CompressionWorker* worker);
    void setIsBusy(bool busy);

    bool isBusy_ = false;
    double progress_ = 0.0;
    QString progressStage_;
    QString lastError_;
    QVariantMap lastStats_;
    QString lastOutputPath_;

    // Liquid Glass design parameters with default values
    double glassOpacity_ = 0.14;
    double glassBlur_ = 24.0;
    double glassFrost_ = 0.65;
    double glassIOR_ = 1.45;
    double glassThickness_ = 1.2;
    double glassBevel_ = 0.8;
    double glassDispersion_ = 0.03;
    double glassMergeDistance_ = 0.0;

    QThread* workerThread_ = nullptr;
};

} // namespace qt_bridge
} // namespace shrinkit

#endif // QT_CORE_LIB
