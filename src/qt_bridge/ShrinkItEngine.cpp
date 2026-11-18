#ifdef QT_CORE_LIB
#include "ShrinkItEngine.h"
#include <QFileInfo>
#include <QDir>
#include <QQuickWindow>
#include <QImage>
#include <stdexcept>

namespace shrinkit {
namespace qt_bridge {

ShrinkItEngine::ShrinkItEngine(QObject* parent) : QObject(parent) {}

ShrinkItEngine::~ShrinkItEngine() {
    if (workerThread_) {
        workerThread_->quit();
        workerThread_->wait(3000);
        workerThread_->deleteLater();
        workerThread_ = nullptr;
    }
}

void ShrinkItEngine::compressFile(const QString& inputPath, const QString& outputPath) {
    if (isBusy_) return;

    auto* worker = new CompressionWorker();
    worker->setCompressTask(inputPath, outputPath);
    startWorkerThread(worker);
}

void ShrinkItEngine::decompressFile(const QString& inputPath, const QString& outputPath) {
    if (isBusy_) return;

    auto* worker = new CompressionWorker();
    worker->setDecompressTask(inputPath, outputPath);
    startWorkerThread(worker);
}

void ShrinkItEngine::analyzeFile(const QString& inputPath) {
    if (isBusy_) return;

    auto* worker = new CompressionWorker();
    worker->setAnalyzeTask(inputPath);
    startWorkerThread(worker);
}

void ShrinkItEngine::inspectFile(const QString& filePath) {
    core::HuffHeader header{};
    std::string origName;
    bool ok = core::HuffmanCompressor::inspectHuffFile(filePath.toStdString(), header, origName);

    if (!ok) {
        lastError_ = "Not a valid .huff archive: " + filePath;
        emit errorOccurred();
        return;
    }

    QVariantMap info;
    info["magic"] = QStringLiteral("HUFF");
    info["version"] = header.version;
    info["originalFileName"] = QString::fromStdString(origName);
    info["originalSize"] = static_cast<qint64>(header.originalSize);
    info["originalSizeFormatted"] = formatBytes(static_cast<qint64>(header.originalSize));
    info["checksum"] = QString("0x%1").arg(header.checksum, 8, 16, QChar('0')).toUpper();
    info["uniqueSymbols"] = header.uniqueSymbols;
    info["paddingBits"] = header.paddingBits;

    QFileInfo fi(filePath);
    info["compressedSize"] = fi.size();
    info["compressedSizeFormatted"] = formatBytes(fi.size());

    lastStats_ = info;
    emit statsReady();
}

void ShrinkItEngine::cancelOperation() {
    if (workerThread_) {
        workerThread_->quit();
        workerThread_->wait(2000);
        workerThread_->deleteLater();
        workerThread_ = nullptr;
        setIsBusy(false);
        progress_ = 0.0;
        progressStage_ = "Cancelled";
        emit progressChanged();
    }
}

void ShrinkItEngine::startWorkerThread(CompressionWorker* worker) {
    setIsBusy(true);
    progress_ = 0.0;
    progressStage_ = "Starting...";
    lastError_ = "";

    workerThread_ = new QThread(this);
    worker->moveToThread(workerThread_);

    connect(workerThread_, &QThread::started, worker, &CompressionWorker::run);
    connect(worker, &CompressionWorker::progressChanged, this, &ShrinkItEngine::onWorkerProgress);
    connect(worker, &CompressionWorker::compressionFinished, this, &ShrinkItEngine::onCompressionFinished);
    connect(worker, &CompressionWorker::decompressionFinished, this, &ShrinkItEngine::onDecompressionFinished);
    connect(worker, &CompressionWorker::analysisFinished, this, &ShrinkItEngine::onAnalysisFinished);
    connect(worker, &CompressionWorker::errorOccurred, this, &ShrinkItEngine::onWorkerError);

    connect(worker, &CompressionWorker::compressionFinished, workerThread_, &QThread::quit);
    connect(worker, &CompressionWorker::decompressionFinished, workerThread_, &QThread::quit);
    connect(worker, &CompressionWorker::analysisFinished, workerThread_, &QThread::quit);
    connect(worker, &CompressionWorker::errorOccurred, workerThread_, &QThread::quit);
    connect(workerThread_, &QThread::finished, worker, &QObject::deleteLater);
    connect(workerThread_, &QThread::finished, workerThread_, &QObject::deleteLater);

    workerThread_->start();
}

void ShrinkItEngine::setIsBusy(bool busy) {
    if (isBusy_ != busy) {
        isBusy_ = busy;
        emit isBusyChanged();
    }
}

void ShrinkItEngine::onWorkerProgress(double progress, const QString& stage) {
    progress_ = progress;
    progressStage_ = stage;
    emit progressChanged();
}

void ShrinkItEngine::onCompressionFinished(const QVariantMap& stats) {
    lastStats_ = stats;
    lastOutputPath_ = stats.value("destinationPath").toString();
    setIsBusy(false);
    emit statsReady();
    emit operationComplete(true, "Compression successful: " + lastOutputPath_);
    workerThread_ = nullptr;
}

void ShrinkItEngine::onDecompressionFinished(bool success, const QString& outputPath) {
    lastOutputPath_ = outputPath;
    setIsBusy(false);
    emit operationComplete(success, success ? "Restored to: " + outputPath : "Decompression failed");
    workerThread_ = nullptr;
}

void ShrinkItEngine::onAnalysisFinished(const QVariantMap& stats) {
    lastStats_ = stats;
    setIsBusy(false);
    emit statsReady();
    emit operationComplete(true, "Analysis complete");
    workerThread_ = nullptr;
}

void ShrinkItEngine::onWorkerError(const QString& errorMessage) {
    lastError_ = errorMessage;
    setIsBusy(false);
    emit errorOccurred();
    emit operationComplete(false, errorMessage);
    workerThread_ = nullptr;
}

QString ShrinkItEngine::formatBytes(qint64 bytes) const {
    return QString::fromStdString(core::CompressionStats::formatBytes(static_cast<uint64_t>(bytes)));
}

qint64 ShrinkItEngine::getFileSize(const QString& path) const {
    QFileInfo fi(path);
    return fi.exists() ? fi.size() : 0;
}

bool ShrinkItEngine::captureWindow(QObject* window, const QString& filePath) {
    if (auto* w = qobject_cast<QQuickWindow*>(window)) {
        QImage img = w->grabWindow();
        return img.save(filePath);
    }
    return false;
}

QString ShrinkItEngine::cleanFilePath(const QUrl& fileUrl) const {
    return QDir::toNativeSeparators(fileUrl.toLocalFile());
}

QString ShrinkItEngine::generateDefaultOutputPath(const QString& inputPath, bool compress) const {
    if (compress) {
        return inputPath + ".huff";
    }
    QFileInfo fi(inputPath);
    QString base = fi.completeBaseName();
    QString dir = fi.absolutePath();
    return QDir::toNativeSeparators(dir + QDir::separator() + "restored_" + base);
}

bool ShrinkItEngine::fileExists(const QString& path) const {
    return QFileInfo::exists(path);
}

// --- Glass Config Setters ---
void ShrinkItEngine::setGlassOpacity(double v) { if (glassOpacity_ != v) { glassOpacity_ = v; emit glassConfigChanged(); } }
void ShrinkItEngine::setGlassBlur(double v)    { if (glassBlur_ != v)    { glassBlur_ = v;    emit glassConfigChanged(); } }
void ShrinkItEngine::setGlassFrost(double v)   { if (glassFrost_ != v)   { glassFrost_ = v;   emit glassConfigChanged(); } }
void ShrinkItEngine::setGlassIOR(double v)     { if (glassIOR_ != v)     { glassIOR_ = v;     emit glassConfigChanged(); } }
void ShrinkItEngine::setGlassThickness(double v){ if (glassThickness_!=v){ glassThickness_=v; emit glassConfigChanged(); } }
void ShrinkItEngine::setGlassBevel(double v)   { if (glassBevel_ != v)   { glassBevel_ = v;   emit glassConfigChanged(); } }
void ShrinkItEngine::setGlassDispersion(double v){ if (glassDispersion_!=v){ glassDispersion_=v; emit glassConfigChanged();} }
void ShrinkItEngine::setGlassMergeDistance(double v){ if (glassMergeDistance_!=v){ glassMergeDistance_=v; emit glassConfigChanged(); } }

void ShrinkItEngine::resetGlassDefaults() {
    glassOpacity_      = 0.14;
    glassBlur_         = 24.0;
    glassFrost_        = 0.65;
    glassIOR_          = 1.45;
    glassThickness_    = 1.2;
    glassBevel_        = 0.8;
    glassDispersion_   = 0.03;
    glassMergeDistance_= 0.0;
    emit glassConfigChanged();
}

} // namespace qt_bridge
} // namespace shrinkit
#endif // QT_CORE_LIB
