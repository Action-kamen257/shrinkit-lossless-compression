#ifdef QT_CORE_LIB
#include "CompressionWorker.h"
#include <stdexcept>

namespace shrinkit {
namespace qt_bridge {

CompressionWorker::CompressionWorker(QObject* parent) : QObject(parent) {}

void CompressionWorker::setCompressTask(const QString& inputPath, const QString& outputPath) {
    inputPath_ = inputPath;
    outputPath_ = outputPath;
    taskType_ = TaskType::Compress;
}

void CompressionWorker::setDecompressTask(const QString& inputPath, const QString& outputPath) {
    inputPath_ = inputPath;
    outputPath_ = outputPath;
    taskType_ = TaskType::Decompress;
}

void CompressionWorker::setAnalyzeTask(const QString& inputPath) {
    inputPath_ = inputPath;
    taskType_ = TaskType::Analyze;
}

void CompressionWorker::run() {
    core::HuffmanCompressor compressor;

    auto progressCb = [this](double progress, const std::string& stage) {
        emit progressChanged(progress, QString::fromStdString(stage));
    };

    if (taskType_ == TaskType::Compress) {
        try {
            core::CompressionStats stats;
            compressor.compressFile(inputPath_.toStdString(), outputPath_.toStdString(), stats, progressCb);
            emit compressionFinished(statsToVariantMap(stats));
        } catch (const std::exception& ex) {
            emit errorOccurred(QString::fromStdString(ex.what()));
        }
    } else if (taskType_ == TaskType::Decompress) {
        try {
            compressor.decompressFile(inputPath_.toStdString(), outputPath_.toStdString(), progressCb);
            emit decompressionFinished(true, outputPath_);
        } catch (const std::exception& ex) {
            emit errorOccurred(QString::fromStdString(ex.what()));
        }
    } else if (taskType_ == TaskType::Analyze) {
        try {
            core::CompressionStats stats;
            compressor.analyzeFile(inputPath_.toStdString(), stats);
            emit analysisFinished(statsToVariantMap(stats));
        } catch (const std::exception& ex) {
            emit errorOccurred(QString::fromStdString(ex.what()));
        }
    }
}

QVariantMap CompressionWorker::statsToVariantMap(const core::CompressionStats& stats) {
    QVariantMap map;
    map["sourcePath"] = QString::fromStdString(stats.sourcePath);
    map["destinationPath"] = QString::fromStdString(stats.destinationPath);
    map["originalFileName"] = QString::fromStdString(stats.originalFileName);
    map["originalSizeBytes"] = static_cast<qint64>(stats.originalSizeBytes);
    map["compressedSizeBytes"] = static_cast<qint64>(stats.compressedSizeBytes);
    map["originalSizeFormatted"] = QString::fromStdString(core::CompressionStats::formatBytes(stats.originalSizeBytes));
    map["compressedSizeFormatted"] = QString::fromStdString(core::CompressionStats::formatBytes(stats.compressedSizeBytes));
    map["compressionRatio"] = stats.compressionRatio;
    map["spaceSavingPercent"] = stats.spaceSavingPercent;
    map["bitsSaved"] = static_cast<qint64>(stats.bitsSaved);
    map["shannonEntropy"] = stats.shannonEntropy;
    map["averageCodeLength"] = stats.averageCodeLength;
    map["codingEfficiency"] = stats.codingEfficiency;
    map["uniqueSymbolCount"] = stats.uniqueSymbolCount;
    map["treeHeight"] = static_cast<int>(stats.treeHeight);
    map["maxCodeLength"] = static_cast<int>(stats.maxCodeLength);
    map["minCodeLength"] = static_cast<int>(stats.minCodeLength);
    map["processingTimeMs"] = stats.processingTimeMs;
    map["throughputMBps"] = stats.throughputMBps;
    map["greedyStepsCount"] = static_cast<int>(stats.greedySteps.size());

    // Build symbol frequency list for QML charts
    QVariantList symFreqs;
    size_t limit = std::min<size_t>(20, stats.symbolFrequencies.size());
    for (size_t i = 0; i < limit; ++i) {
        uint8_t sym = stats.symbolFrequencies[i].first;
        uint64_t freq = stats.symbolFrequencies[i].second;
        QVariantMap entry;
        char printable = (sym >= 32 && sym <= 126) ? static_cast<char>(sym) : '.';
        entry["symbol"] = QChar(printable);
        entry["byte"] = static_cast<int>(sym);
        entry["frequency"] = static_cast<qint64>(freq);
        auto it = stats.huffmanCodes.find(sym);
        entry["code"] = (it != stats.huffmanCodes.end())
                            ? QString::fromStdString(it->second.toString())
                            : QString("-");
        entry["codeLength"] = (it != stats.huffmanCodes.end()) ? it->second.length : 0;
        symFreqs.append(entry);
    }
    map["symbolFrequencies"] = symFreqs;

    // Greedy algorithm step trace for the visualization view
    QVariantList steps;
    for (const auto& step : stats.greedySteps) {
        QVariantMap s;
        s["stepNumber"] = static_cast<int>(step.stepNumber);
        s["description"] = QString::fromStdString(step.description);
        s["mergedFrequency"] = static_cast<qint64>(step.mergedFrequency);
        s["leftChild"] = QString::fromStdString(step.leftChildDesc);
        s["rightChild"] = QString::fromStdString(step.rightChildDesc);
        steps.append(s);
    }
    map["greedySteps"] = steps;

    return map;
}

} // namespace qt_bridge
} // namespace shrinkit
#endif // QT_CORE_LIB
