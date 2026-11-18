#pragma once

#include "BitCode.h"
#include <cstdint>
#include <string>
#include <vector>
#include <unordered_map>
#include <cmath>
#include <sstream>
#include <iomanip>

namespace shrinkit {
namespace core {

struct AlgorithmStep {
    size_t stepNumber = 0;
    std::string description;
    uint64_t mergedFrequency = 0;
    std::string leftChildDesc;
    std::string rightChildDesc;
};

struct CompressionStats {
    std::string sourcePath;
    std::string destinationPath;
    std::string originalFileName;

    uint64_t originalSizeBytes = 0;
    uint64_t compressedSizeBytes = 0;
    double compressionRatio = 1.0;       // original / compressed (e.g., 2.15x)
    double spaceSavingPercent = 0.0;     // (1 - compressed / original) * 100%
    int64_t bitsSaved = 0;

    double shannonEntropy = 0.0;         // Theoretical minimum bits per symbol
    double averageCodeLength = 0.0;      // Actual average bits per symbol
    double codingEfficiency = 0.0;       // (entropy / averageCodeLength) * 100%

    uint16_t uniqueSymbolCount = 0;
    size_t treeHeight = 0;
    size_t maxCodeLength = 0;
    size_t minCodeLength = 0;

    double processingTimeMs = 0.0;
    double throughputMBps = 0.0;

    // Detailed breakdown for visualizations
    std::vector<std::pair<uint8_t, uint64_t>> symbolFrequencies; // sorted by frequency descending
    std::unordered_map<uint8_t, BitCode> huffmanCodes;
    std::vector<AlgorithmStep> greedySteps;                       // Trace of greedy merges

    static std::string formatBytes(uint64_t bytes) {
        constexpr double KB = 1024.0;
        constexpr double MB = KB * 1024.0;
        constexpr double GB = MB * 1024.0;

        std::ostringstream oss;
        oss << std::fixed << std::setprecision(2);

        if (bytes >= GB) {
            oss << (bytes / GB) << " GB";
        } else if (bytes >= MB) {
            oss << (bytes / MB) << " MB";
        } else if (bytes >= KB) {
            oss << (bytes / KB) << " KB";
        } else {
            oss << bytes << " B";
        }
        return oss.str();
    }
};

} // namespace core
} // namespace shrinkit
