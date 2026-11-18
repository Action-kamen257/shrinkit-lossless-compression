#pragma once

#ifdef QT_CORE_LIB
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QThread>

#include "HuffmanCompressor.h"
#include "CompressionStats.h"

namespace shrinkit {
namespace qt_bridge {

/**
 * @brief Worker thread that runs compression/decompression without blocking the QML UI.
 */
class CompressionWorker : public QObject {
    Q_OBJECT
public:
    explicit CompressionWorker(QObject* parent = nullptr);

    void setCompressTask(const QString& inputPath, const QString& outputPath);
    void setDecompressTask(const QString& inputPath, const QString& outputPath);
    void setAnalyzeTask(const QString& inputPath);

public slots:
    void run();

signals:
    void progressChanged(double progress, const QString& stage);
    void compressionFinished(const QVariantMap& stats);
    void decompressionFinished(bool success, const QString& outputPath);
    void analysisFinished(const QVariantMap& stats);
    void errorOccurred(const QString& errorMessage);

private:
    QString inputPath_;
    QString outputPath_;
    enum class TaskType { Compress, Decompress, Analyze } taskType_ = TaskType::Compress;

    static QVariantMap statsToVariantMap(const core::CompressionStats& stats);
};

} // namespace qt_bridge
} // namespace shrinkit

#endif // QT_CORE_LIB
