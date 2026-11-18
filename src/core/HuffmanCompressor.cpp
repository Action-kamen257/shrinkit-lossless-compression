#include "HuffmanCompressor.h"
#include "BitStream.h"
#include "LZ77.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <stdexcept>
#include <filesystem>
#include <cstring>

namespace fs = std::filesystem;

namespace shrinkit {
namespace core {

namespace {

std::string extractFileName(const std::string& path) {
    fs::path p(path);
    return p.filename().string();
}

} // anonymous namespace

bool HuffmanCompressor::compressFile(const std::string& inputFilePath,
                                    const std::string& outputFilePath,
                                    CompressionStats& outStats,
                                    ProgressCallback progressCb) {
    auto startTime = std::chrono::high_resolution_clock::now();

    outStats.sourcePath = inputFilePath;
    outStats.destinationPath = outputFilePath;
    outStats.originalFileName = extractFileName(inputFilePath);

    std::ifstream in(inputFilePath, std::ios::binary | std::ios::ate);
    if (!in.is_open()) {
        throw std::runtime_error("Failed to open source file for reading: " + inputFilePath);
    }

    uint64_t fileSize = static_cast<uint64_t>(in.tellg());
    in.seekg(0, std::ios::beg);
    outStats.originalSizeBytes = fileSize;

    if (progressCb) progressCb(0.05, "Reading input file");

    std::vector<uint8_t> inputData(fileSize);
    if (fileSize > 0) {
        in.read(reinterpret_cast<char*>(inputData.data()), fileSize);
    }
    in.close();

    uint32_t checksum = Checksum::adler32(inputData.data(), fileSize);

    // Handle 0-byte file
    if (fileSize == 0) {
        std::ofstream out(outputFilePath, std::ios::binary | std::ios::trunc);
        HuffHeader header{};
        header.magic = HUFF_MAGIC;
        header.version = HUFF_VERSION;
        header.flags = FLAG_HAS_CHECKSUM | FLAG_HAS_FILENAME | FLAG_METHOD_RAW_HUFF;
        header.originalSize = 0;
        header.checksum = checksum;
        header.fileNameLength = static_cast<uint16_t>(outStats.originalFileName.size());
        out.write(reinterpret_cast<const char*>(&header), sizeof(HuffHeader));
        if (header.fileNameLength > 0) {
            out.write(outStats.originalFileName.data(), header.fileNameLength);
        }
        out.close();

        outStats.compressedSizeBytes = fs::file_size(outputFilePath);
        outStats.compressionRatio = 1.0;
        outStats.spaceSavingPercent = 0.0;
        outStats.processingTimeMs = 0.1;
        if (progressCb) progressCb(1.0, "Complete");
        return true;
    }

    if (progressCb) progressCb(0.15, "Analyzing compression strategies");

    // Strategy 1: LZ77 dictionary pre-pass + Huffman Coding (Deflate-style)
    std::vector<uint8_t> lzData = LZ77::compress(inputData.data(), fileSize);

    // Build frequency table for both: LZ stream and raw stream to pick optimal
    std::array<uint64_t, 256> lzFreqs{};
    std::array<uint64_t, 256> rawFreqs{};

    for (uint8_t b : lzData) ++lzFreqs[b];
    for (uint8_t b : inputData) ++rawFreqs[b];

    HuffmanTree lzTree;
    lzTree.buildFromFrequencies(lzFreqs, &outStats.greedySteps);
    auto lzCodes = lzTree.generateCodes();

    HuffmanTree rawTree;
    rawTree.buildFromFrequencies(rawFreqs);
    auto rawCodes = rawTree.generateCodes();

    // Calculate approximate bit lengths
    uint64_t lzTotalBits = 0;
    for (size_t i = 0; i < 256; ++i) {
        if (lzFreqs[i] > 0) lzTotalBits += lzFreqs[i] * lzCodes[static_cast<uint8_t>(i)].length;
    }

    uint64_t rawTotalBits = 0;
    for (size_t i = 0; i < 256; ++i) {
        if (rawFreqs[i] > 0) rawTotalBits += rawFreqs[i] * rawCodes[static_cast<uint8_t>(i)].length;
    }

    // Determine optimal mode: LZ77+Huffman vs Raw Huffman vs Stored fallback
    bool useLz = (lzTotalBits < rawTotalBits) && (lzData.size() < fileSize * 1.05);
    const auto& selectedData = useLz ? lzData : inputData;
    const auto& selectedCodes = useLz ? lzCodes : rawCodes;
    auto& selectedTree = useLz ? lzTree : rawTree;
    const auto& selectedFreqs = useLz ? lzFreqs : rawFreqs;

    // Populate stats
    outStats.symbolFrequencies.clear();
    for (size_t i = 0; i < 256; ++i) {
        if (rawFreqs[i] > 0) {
            outStats.symbolFrequencies.emplace_back(static_cast<uint8_t>(i), rawFreqs[i]);
        }
    }
    std::sort(outStats.symbolFrequencies.begin(), outStats.symbolFrequencies.end(),
              [](const auto& a, const auto& b) { return a.second > b.second; });

    outStats.huffmanCodes = rawCodes;
    outStats.uniqueSymbolCount = static_cast<uint16_t>(outStats.symbolFrequencies.size());
    outStats.treeHeight = rawTree.height();
    outStats.shannonEntropy = rawTree.calculateEntropy(rawFreqs);
    outStats.averageCodeLength = rawTree.calculateAverageCodeLength(rawFreqs, rawCodes);
    outStats.codingEfficiency = outStats.averageCodeLength > 0 ? (outStats.shannonEntropy / outStats.averageCodeLength) * 100.0 : 100.0;

    size_t minLen = 64, maxLen = 0;
    for (const auto& [sym, code] : rawCodes) {
        minLen = std::min<size_t>(minLen, code.length);
        maxLen = std::max<size_t>(maxLen, code.length);
    }
    outStats.minCodeLength = rawCodes.empty() ? 0 : minLen;
    outStats.maxCodeLength = maxLen;

    // Estimate payload size
    uint64_t estCompressedSize = sizeof(HuffHeader) + outStats.originalFileName.size() +
                                 (selectedTree.leafCount() * 10 / 8) + (useLz ? (lzTotalBits + 7) / 8 : (rawTotalBits + 7) / 8);

    bool shouldStoreRaw = (fileSize < 64 && estCompressedSize > fileSize);

    std::ofstream out(outputFilePath, std::ios::binary | std::ios::trunc);
    if (!out.is_open()) {
        throw std::runtime_error("Failed to create destination file: " + outputFilePath);
    }

    if (progressCb) progressCb(0.35, "Writing .huff header & compact tree");

    HuffHeader header{};
    header.magic = HUFF_MAGIC;
    header.version = HUFF_VERSION;
    header.originalSize = fileSize;
    header.checksum = checksum;
    header.fileNameLength = static_cast<uint16_t>(outStats.originalFileName.size());
    header.uniqueSymbols = static_cast<uint16_t>(selectedTree.leafCount());

    if (shouldStoreRaw) {
        header.flags = FLAG_HAS_CHECKSUM | FLAG_HAS_FILENAME | FLAG_METHOD_STORED;
        header.paddingBits = 0;
        out.write(reinterpret_cast<const char*>(&header), sizeof(HuffHeader));
        if (header.fileNameLength > 0) {
            out.write(outStats.originalFileName.data(), header.fileNameLength);
        }
        out.write(reinterpret_cast<const char*>(inputData.data()), fileSize);
    } else {
        header.flags = FLAG_HAS_CHECKSUM | FLAG_HAS_FILENAME |
                       (useLz ? FLAG_METHOD_LZ_HUFF : FLAG_METHOD_RAW_HUFF);
        header.paddingBits = 0;

        // Write header placeholder
        out.write(reinterpret_cast<const char*>(&header), sizeof(HuffHeader));
        if (header.fileNameLength > 0) {
            out.write(outStats.originalFileName.data(), header.fileNameLength);
        }

        // Write compact serialized tree topology & symbols
        BitWriter bitWriter(out);
        selectedTree.serializeTree(bitWriter);

        if (progressCb) progressCb(0.50, "Encoding greedy Huffman bitstream");

        // Encode payload
        for (uint8_t byte : selectedData) {
            bitWriter.writeCode(selectedCodes.at(byte));
        }

        uint8_t pad = bitWriter.flush();
        header.paddingBits = pad;

        // Update header with padding bits
        out.seekp(0, std::ios::beg);
        out.write(reinterpret_cast<const char*>(&header), sizeof(HuffHeader));
    }

    out.close();

    uint64_t compSize = fs::file_size(outputFilePath);
    outStats.compressedSizeBytes = compSize;

    if (compSize > 0) {
        outStats.compressionRatio = static_cast<double>(fileSize) / static_cast<double>(compSize);
    } else {
        outStats.compressionRatio = 1.0;
    }

    if (fileSize > 0) {
        outStats.spaceSavingPercent = (1.0 - (static_cast<double>(compSize) / static_cast<double>(fileSize))) * 100.0;
    } else {
        outStats.spaceSavingPercent = 0.0;
    }

    int64_t origBits = static_cast<int64_t>(fileSize * 8);
    int64_t compBits = static_cast<int64_t>(compSize * 8);
    outStats.bitsSaved = origBits - compBits;

    auto endTime = std::chrono::high_resolution_clock::now();
    outStats.processingTimeMs = std::chrono::duration<double, std::milli>(endTime - startTime).count();
    double seconds = outStats.processingTimeMs / 1000.0;
    if (seconds > 0.0) {
        outStats.throughputMBps = (static_cast<double>(fileSize) / (1024.0 * 1024.0)) / seconds;
    }

    if (progressCb) progressCb(1.0, "Compression finished");
    return true;
}

bool HuffmanCompressor::decompressFile(const std::string& inputFilePath,
                                      const std::string& outputFilePath,
                                      ProgressCallback progressCb) {
    if (progressCb) progressCb(0.05, "Reading .huff archive header");

    std::ifstream in(inputFilePath, std::ios::binary);
    if (!in.is_open()) {
        throw std::runtime_error("Failed to open compressed file: " + inputFilePath);
    }

    HuffHeader header{};
    in.read(reinterpret_cast<char*>(&header), sizeof(HuffHeader));
    if (in.gcount() != sizeof(HuffHeader)) {
        throw std::runtime_error("File is too small or truncated: invalid .huff header");
    }

    if (header.magic != HUFF_MAGIC) {
        throw std::runtime_error("Invalid file format: Magic header signature does not match 'HUFF'");
    }

    // Read original filename
    std::string originalFileName;
    if (header.fileNameLength > 0) {
        std::vector<char> fnBuf(header.fileNameLength);
        in.read(fnBuf.data(), header.fileNameLength);
        originalFileName.assign(fnBuf.data(), header.fileNameLength);
    }

    // 0-byte file edge case
    if (header.originalSize == 0) {
        std::ofstream out(outputFilePath, std::ios::binary | std::ios::trunc);
        if (progressCb) progressCb(1.0, "Decompression finished (Empty file)");
        return true;
    }

    std::ofstream out(outputFilePath, std::ios::binary | std::ios::trunc);
    if (!out.is_open()) {
        throw std::runtime_error("Failed to open destination file for writing: " + outputFilePath);
    }

    // Mode: Stored fallback
    if (header.flags & FLAG_METHOD_STORED) {
        std::vector<uint8_t> data(header.originalSize);
        in.read(reinterpret_cast<char*>(data.data()), header.originalSize);
        out.write(reinterpret_cast<const char*>(data.data()), header.originalSize);
        out.close();
        in.close();

        uint32_t calcCheck = Checksum::adler32(data.data(), header.originalSize);
        if ((header.flags & FLAG_HAS_CHECKSUM) && calcCheck != header.checksum) {
            throw std::runtime_error("Checksum mismatch on stored file!");
        }
        if (progressCb) progressCb(1.0, "Decompression finished");
        return true;
    }

    // Mode: Version 1 (legacy table) vs Version 2 (compact serialized tree)
    std::shared_ptr<HuffmanNode> root = nullptr;
    BitReader bitReader(in);

    if (header.version == 1) {
        std::array<uint64_t, 256> frequencies{};
        frequencies.fill(0);
        for (uint16_t i = 0; i < header.uniqueSymbols; ++i) {
            uint8_t sym = static_cast<uint8_t>(in.get());
            uint64_t freq = 0;
            in.read(reinterpret_cast<char*>(&freq), sizeof(uint64_t));
            frequencies[sym] = freq;
        }
        HuffmanTree tree;
        tree.buildFromFrequencies(frequencies);
        root = tree.root();
    } else {
        // Version 2: deserialize compact tree from bitstream
        if (progressCb) progressCb(0.20, "Rebuilding Huffman Binary Tree");
        root = HuffmanTree::deserializeTree(bitReader);
    }

    if (!root) {
        throw std::runtime_error("Failed to reconstruct Huffman binary tree from archive");
    }

    if (progressCb) progressCb(0.35, "Decoding Huffman bitstream");

    // Decode symbols from bitstream
    std::vector<uint8_t> decodedBytes;
    bool isLz = (header.flags & FLAG_METHOD_LZ_HUFF) != 0;

    auto currentNode = root;

    // Single unique symbol special case
    if (root->left && root->left->isLeaf() && !root->right) {
        uint8_t sym = root->left->symbol;
        size_t targetCount = isLz ? header.originalSize * 3 : header.originalSize;
        while (decodedBytes.size() < targetCount) {
            int bit = bitReader.readBit();
            if (bit == -1) break;
            decodedBytes.push_back(sym);
        }
    } else {
        while (true) {
            int bit = bitReader.readBit();
            if (bit == -1) break;

            currentNode = (bit == 0) ? currentNode->left : currentNode->right;
            if (!currentNode) {
                throw std::runtime_error("Corrupted bitstream: encountered null node during tree traversal");
            }

            if (currentNode->isLeaf()) {
                decodedBytes.push_back(currentNode->symbol);
                currentNode = root;

                // If pure Huffman without LZ, we can stop once originalSize is reached
                if (!isLz && decodedBytes.size() == header.originalSize) {
                    break;
                }
            }
        }
    }

    in.close();

    // If LZ77 was used, decompress the token stream back to original bytes
    std::vector<uint8_t> finalOutput;
    if (isLz) {
        if (progressCb) progressCb(0.75, "Expanding LZ77 dictionary matches");
        bool lzOk = LZ77::decompress(decodedBytes.data(), decodedBytes.size(), finalOutput, header.originalSize);
        if (!lzOk || finalOutput.size() != header.originalSize) {
            throw std::runtime_error("LZ77 dictionary decompression failed or truncated");
        }
    } else {
        finalOutput = std::move(decodedBytes);
    }

    out.write(reinterpret_cast<const char*>(finalOutput.data()), finalOutput.size());
    out.close();

    // Verify Checksum
    uint32_t calcCheck = Checksum::adler32(finalOutput.data(), finalOutput.size());
    if ((header.flags & FLAG_HAS_CHECKSUM) && calcCheck != header.checksum) {
        throw std::runtime_error("Checksum mismatch! Data corrupted. Expected: 0x" +
                                 std::to_string(header.checksum) + ", Computed: 0x" +
                                 std::to_string(calcCheck));
    }

    if (progressCb) progressCb(1.0, "Decompression finished (100% Lossless Match)");
    return true;
}

bool HuffmanCompressor::analyzeFile(const std::string& inputFilePath, CompressionStats& outStats) {
    outStats.sourcePath = inputFilePath;
    outStats.originalFileName = extractFileName(inputFilePath);

    std::ifstream in(inputFilePath, std::ios::binary | std::ios::ate);
    if (!in.is_open()) return false;

    uint64_t fileSize = static_cast<uint64_t>(in.tellg());
    in.seekg(0, std::ios::beg);
    outStats.originalSizeBytes = fileSize;

    std::vector<uint8_t> inputData(fileSize);
    if (fileSize > 0) in.read(reinterpret_cast<char*>(inputData.data()), fileSize);
    in.close();

    std::array<uint64_t, 256> rawFreqs{};
    for (uint8_t b : inputData) ++rawFreqs[b];

    HuffmanTree rawTree;
    rawTree.buildFromFrequencies(rawFreqs, &outStats.greedySteps);
    auto rawCodes = rawTree.generateCodes();

    outStats.symbolFrequencies.clear();
    for (size_t i = 0; i < 256; ++i) {
        if (rawFreqs[i] > 0) outStats.symbolFrequencies.emplace_back(static_cast<uint8_t>(i), rawFreqs[i]);
    }
    std::sort(outStats.symbolFrequencies.begin(), outStats.symbolFrequencies.end(),
              [](const auto& a, const auto& b) { return a.second > b.second; });

    outStats.huffmanCodes = rawCodes;
    outStats.uniqueSymbolCount = static_cast<uint16_t>(outStats.symbolFrequencies.size());
    outStats.treeHeight = rawTree.height();
    outStats.shannonEntropy = rawTree.calculateEntropy(rawFreqs);
    outStats.averageCodeLength = rawTree.calculateAverageCodeLength(rawFreqs, rawCodes);
    outStats.codingEfficiency = outStats.averageCodeLength > 0 ? (outStats.shannonEntropy / outStats.averageCodeLength) * 100.0 : 100.0;

    // Test LZ77 compression
    std::vector<uint8_t> lzData = LZ77::compress(inputData.data(), fileSize);
    std::array<uint64_t, 256> lzFreqs{};
    for (uint8_t b : lzData) ++lzFreqs[b];

    HuffmanTree lzTree;
    lzTree.buildFromFrequencies(lzFreqs);
    auto lzCodes = lzTree.generateCodes();

    uint64_t lzTotalBits = 0;
    for (size_t i = 0; i < 256; ++i) {
        if (lzFreqs[i] > 0) lzTotalBits += lzFreqs[i] * lzCodes[static_cast<uint8_t>(i)].length;
    }

    uint64_t payloadBytes = (lzTotalBits + 7) / 8;
    uint64_t treeBytes = lzTree.leafCount() * 10 / 8;
    outStats.compressedSizeBytes = sizeof(HuffHeader) + outStats.originalFileName.size() + treeBytes + payloadBytes;

    if (fileSize > 0) {
        outStats.compressionRatio = static_cast<double>(fileSize) / static_cast<double>(outStats.compressedSizeBytes);
        outStats.spaceSavingPercent = (1.0 - (static_cast<double>(outStats.compressedSizeBytes) / static_cast<double>(fileSize))) * 100.0;
        outStats.bitsSaved = static_cast<int64_t>(fileSize * 8) - static_cast<int64_t>(outStats.compressedSizeBytes * 8);
    }

    return true;
}

bool HuffmanCompressor::compressBuffer(const std::vector<uint8_t>& input,
                                      std::vector<uint8_t>& output,
                                      CompressionStats* outStats) {
    std::string tempIn = "temp_buffer_in.bin";
    std::string tempOut = "temp_buffer_out.huff";

    {
        std::ofstream ofs(tempIn, std::ios::binary);
        ofs.write(reinterpret_cast<const char*>(input.data()), input.size());
    }

    CompressionStats localStats;
    bool ok = compressFile(tempIn, tempOut, localStats);
    if (outStats) *outStats = localStats;

    if (ok) {
        std::ifstream ifs(tempOut, std::ios::binary | std::ios::ate);
        size_t sz = ifs.tellg();
        ifs.seekg(0, std::ios::beg);
        output.resize(sz);
        ifs.read(reinterpret_cast<char*>(output.data()), sz);
    }

    fs::remove(tempIn);
    fs::remove(tempOut);
    return ok;
}

bool HuffmanCompressor::decompressBuffer(const std::vector<uint8_t>& input,
                                        std::vector<uint8_t>& output) {
    std::string tempIn = "temp_buffer_in.huff";
    std::string tempOut = "temp_buffer_out.bin";

    {
        std::ofstream ofs(tempIn, std::ios::binary);
        ofs.write(reinterpret_cast<const char*>(input.data()), input.size());
    }

    bool ok = decompressFile(tempIn, tempOut);
    if (ok) {
        std::ifstream ifs(tempOut, std::ios::binary | std::ios::ate);
        size_t sz = ifs.tellg();
        ifs.seekg(0, std::ios::beg);
        output.resize(sz);
        ifs.read(reinterpret_cast<char*>(output.data()), sz);
    }

    fs::remove(tempIn);
    fs::remove(tempOut);
    return ok;
}

bool HuffmanCompressor::inspectHuffFile(const std::string& filePath,
                                       HuffHeader& outHeader,
                                       std::string& outOriginalFileName) {
    std::ifstream in(filePath, std::ios::binary);
    if (!in.is_open()) return false;

    in.read(reinterpret_cast<char*>(&outHeader), sizeof(HuffHeader));
    if (in.gcount() != sizeof(HuffHeader) || outHeader.magic != HUFF_MAGIC) {
        return false;
    }

    if (outHeader.fileNameLength > 0) {
        std::vector<char> fn(outHeader.fileNameLength);
        in.read(fn.data(), outHeader.fileNameLength);
        outOriginalFileName.assign(fn.data(), outHeader.fileNameLength);
    }
    return true;
}

bool HuffmanCompressor::verifyLosslessIntegrity(const std::string& file1, const std::string& file2) {
    std::ifstream f1(file1, std::ios::binary | std::ios::ate);
    std::ifstream f2(file2, std::ios::binary | std::ios::ate);

    if (!f1.is_open() || !f2.is_open()) return false;
    if (f1.tellg() != f2.tellg()) return false;

    uint64_t size = static_cast<uint64_t>(f1.tellg());
    f1.seekg(0, std::ios::beg);
    f2.seekg(0, std::ios::beg);

    std::vector<char> buf1(BUFFER_SIZE);
    std::vector<char> buf2(BUFFER_SIZE);

    uint64_t remaining = size;
    while (remaining > 0) {
        size_t toRead = static_cast<size_t>(std::min<uint64_t>(BUFFER_SIZE, remaining));
        f1.read(buf1.data(), toRead);
        f2.read(buf2.data(), toRead);

        if (f1.gcount() != f2.gcount()) return false;
        if (std::memcmp(buf1.data(), buf2.data(), f1.gcount()) != 0) {
            return false;
        }
        remaining -= f1.gcount();
    }

    return true;
}

} // namespace core
} // namespace shrinkit
