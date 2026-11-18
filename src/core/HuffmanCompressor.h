#pragma once

#include "FileFormat.h"
#include "HuffmanTree.h"
#include "CompressionStats.h"
#include "Checksum.h"
#include <string>
#include <vector>
#include <functional>
#include <chrono>

namespace shrinkit {
namespace core {

using ProgressCallback = std::function<void(double progress, const std::string& stage)>;

/**
 * @brief High-performance Huffman compression and decompression engine.
 *
 * Implements the complete lossless compression pipeline according to the custom .huff specification.
 */
class HuffmanCompressor {
public:
    HuffmanCompressor() = default;
    ~HuffmanCompressor() = default;

    // Compresses a file into the custom .huff format.
    bool compressFile(const std::string& inputFilePath,
                      const std::string& outputFilePath,
                      CompressionStats& outStats,
                      ProgressCallback progressCb = nullptr);

    // Decompresses a .huff file back to its original uncompressed data.
    bool decompressFile(const std::string& inputFilePath,
                        const std::string& outputFilePath,
                        ProgressCallback progressCb = nullptr);

    // Analyzes a file without writing compressed output (calculates theoretical entropy, frequencies, etc.)
    bool analyzeFile(const std::string& inputFilePath,
                     CompressionStats& outStats);

    // In-memory compression for testing and micro-benchmarking
    bool compressBuffer(const std::vector<uint8_t>& input,
                        std::vector<uint8_t>& output,
                        CompressionStats* outStats = nullptr);

    // In-memory decompression for testing and micro-benchmarking
    bool decompressBuffer(const std::vector<uint8_t>& input,
                          std::vector<uint8_t>& output);

    // Inspects a .huff file header without performing full decompression
    static bool inspectHuffFile(const std::string& filePath,
                                HuffHeader& outHeader,
                                std::string& outOriginalFileName);

    // Verifies that two files are byte-for-byte identical
    static bool verifyLosslessIntegrity(const std::string& file1,
                                       const std::string& file2);

private:
    static constexpr size_t BUFFER_SIZE = 64 * 1024; // 64 KB streaming buffer
};

} // namespace core
} // namespace shrinkit
