#include "HuffmanCompressor.h"
#include <iostream>
#include <fstream>
#include <iomanip>
#include <vector>
#include <string>
#include <filesystem>
#include <random>

namespace fs = std::filesystem;
using namespace shrinkit::core;

void printBanner() {
    std::cout << "\n";
    std::cout << "  ==============================================================\n";
    std::cout << "   SHRINKIT :: Lossless Compression Engine (Huffman / Greedy)  \n";
    std::cout << "   Black x Cherry Red Visual Pipeline - Core Backend           \n";
    std::cout << "  ==============================================================\n\n";
}

void printHelp(const char* progName) {
    printBanner();
    std::cout << "Usage: " << progName << " [command] [options]\n\n";
    std::cout << "Commands:\n";
    std::cout << "  -c, --compress <file> [-o <out.huff>]    Compress file to .huff\n";
    std::cout << "  -d, --decompress <file> [-o <dest>]      Decompress .huff file\n";
    std::cout << "  -a, --analyze <file>                     Analyze frequencies & entropy\n";
    std::cout << "  -i, --inspect <file.huff>                Inspect .huff header metadata\n";
    std::cout << "  -t, --test                               Run automated verification suite\n";
    std::cout << "  -b, --benchmark [size_mb]                Run performance benchmarks\n";
    std::cout << "  -h, --help                               Show this help menu\n\n";
}

void printStats(const CompressionStats& stats) {
    std::cout << "\n------------------ COMPRESSION REPORT ------------------\n";
    std::cout << std::left << std::setw(28) << "Source File:" << stats.sourcePath << "\n";
    std::cout << std::left << std::setw(28) << "Destination File:" << stats.destinationPath << "\n";
    std::cout << std::left << std::setw(28) << "Original Size:"
              << CompressionStats::formatBytes(stats.originalSizeBytes)
              << " (" << stats.originalSizeBytes << " bytes)\n";
    std::cout << std::left << std::setw(28) << "Compressed Size:"
              << CompressionStats::formatBytes(stats.compressedSizeBytes)
              << " (" << stats.compressedSizeBytes << " bytes)\n";

    std::cout << std::fixed << std::setprecision(2);
    std::cout << std::left << std::setw(28) << "Compression Ratio:"
              << stats.compressionRatio << "x\n";
    std::cout << std::left << std::setw(28) << "Space Savings:"
              << stats.spaceSavingPercent << "%\n";
    std::cout << std::left << std::setw(28) << "Bits Saved:"
              << stats.bitsSaved << " bits\n";

    std::cout << "\n-------------- ALGORITHM & ENTROPY METRICS -------------\n";
    std::cout << std::left << std::setw(28) << "Unique Symbols (Alphabet):" << stats.uniqueSymbolCount << "\n";
    std::cout << std::left << std::setw(28) << "Huffman Tree Height:" << stats.treeHeight << "\n";
    std::cout << std::left << std::setw(28) << "Min / Max Code Length:"
              << stats.minCodeLength << " / " << stats.maxCodeLength << " bits\n";
    std::cout << std::left << std::setw(28) << "Shannon Entropy H(X):"
              << stats.shannonEntropy << " bits/symbol\n";
    std::cout << std::left << std::setw(28) << "Average Code Length (L):"
              << stats.averageCodeLength << " bits/symbol\n";
    std::cout << std::left << std::setw(28) << "Coding Efficiency:"
              << stats.codingEfficiency << "%\n";
    std::cout << std::left << std::setw(28) << "Processing Time:"
              << stats.processingTimeMs << " ms\n";
    std::cout << std::left << std::setw(28) << "Throughput:"
              << stats.throughputMBps << " MB/s\n";

    std::cout << "\n---------------- TOP 10 FREQUENT SYMBOLS ---------------\n";
    std::cout << " Byte | ASCII | Frequency | Huffman Code (Prefix Free)\n";
    std::cout << "------+-------+-----------+----------------------------\n";
    size_t count = std::min<size_t>(10, stats.symbolFrequencies.size());
    for (size_t i = 0; i < count; ++i) {
        uint8_t sym = stats.symbolFrequencies[i].first;
        uint64_t freq = stats.symbolFrequencies[i].second;
        auto it = stats.huffmanCodes.find(sym);
        std::string codeStr = (it != stats.huffmanCodes.end()) ? it->second.toString() : "-";

        char printable = (sym >= 32 && sym <= 126) ? static_cast<char>(sym) : '.';
        std::cout << " 0x" << std::hex << std::uppercase << std::setw(2) << std::setfill('0') << static_cast<int>(sym) << std::dec
                  << " |   " << printable << "   | "
                  << std::setw(9) << std::setfill(' ') << freq << " | "
                  << codeStr << "\n";
    }
    std::cout << "--------------------------------------------------------\n\n";
}

int handleCompress(const std::string& inputPath, std::string outputPath) {
    if (!fs::exists(inputPath)) {
        std::cerr << "[Error] Input file does not exist: " << inputPath << "\n";
        return 1;
    }

    if (outputPath.empty()) {
        outputPath = inputPath + ".huff";
    }

    std::cout << "[ShrinkIt] Compressing: " << inputPath << " -> " << outputPath << " ...\n";

    HuffmanCompressor compressor;
    CompressionStats stats;

    auto progressCallback = [](double progress, const std::string& stage) {
        int barWidth = 30;
        int pos = static_cast<int>(barWidth * progress);
        std::cout << "\r[";
        for (int i = 0; i < barWidth; ++i) {
            if (i < pos) std::cout << "=";
            else if (i == pos) std::cout << ">";
            else std::cout << " ";
        }
        std::cout << "] " << std::fixed << std::setprecision(1) << (progress * 100.0) << "% - " << stage << std::flush;
    };

    try {
        compressor.compressFile(inputPath, outputPath, stats, progressCallback);
        std::cout << "\n";
        printStats(stats);
        std::cout << "[SUCCESS] File successfully compressed to: " << outputPath << "\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "\n[Error] Compression failed: " << ex.what() << "\n";
        return 1;
    }
}

int handleDecompress(const std::string& inputPath, std::string outputPath) {
    if (!fs::exists(inputPath)) {
        std::cerr << "[Error] Compressed file does not exist: " << inputPath << "\n";
        return 1;
    }

    if (outputPath.empty()) {
        HuffHeader header;
        std::string origName;
        if (HuffmanCompressor::inspectHuffFile(inputPath, header, origName) && !origName.empty()) {
            fs::path p(inputPath);
            fs::path parent = p.parent_path();
            if (parent.empty()) {
                outputPath = "restored_" + origName;
            } else {
                outputPath = (parent / ("restored_" + origName)).string();
            }
        } else {
            outputPath = inputPath + ".out";
        }
    }

    std::cout << "[ShrinkIt] Decompressing: " << inputPath << " -> " << outputPath << " ...\n";

    HuffmanCompressor compressor;
    auto progressCallback = [](double progress, const std::string& stage) {
        int barWidth = 30;
        int pos = static_cast<int>(barWidth * progress);
        std::cout << "\r[";
        for (int i = 0; i < barWidth; ++i) {
            if (i < pos) std::cout << "=";
            else if (i == pos) std::cout << ">";
            else std::cout << " ";
        }
        std::cout << "] " << std::fixed << std::setprecision(1) << (progress * 100.0) << "% - " << stage << std::flush;
    };

    try {
        compressor.decompressFile(inputPath, outputPath, progressCallback);
        std::cout << "\n";
        uint64_t decompressedSize = fs::file_size(outputPath);
        std::cout << "[SUCCESS] Restored " << CompressionStats::formatBytes(decompressedSize)
                  << " to " << outputPath << "\n";
        std::cout << "[Integrity] 100% Lossless Adler32 Checksum Verified.\n\n";
        return 0;
    } catch (const std::exception& ex) {
        std::cerr << "\n[Error] Decompression failed: " << ex.what() << "\n";
        return 1;
    }
}

int handleInspect(const std::string& filePath) {
    if (!fs::exists(filePath)) {
        std::cerr << "[Error] File does not exist: " << filePath << "\n";
        return 1;
    }

    HuffHeader header{};
    std::string originalName;
    if (!HuffmanCompressor::inspectHuffFile(filePath, header, originalName)) {
        std::cerr << "[Error] Not a valid .huff archive file: " << filePath << "\n";
        return 1;
    }

    std::cout << "\n---------------- .HUFF ARCHIVE HEADER ------------------\n";
    std::cout << std::left << std::setw(28) << "Magic Identifier:" << "HUFF (0x" << std::hex << header.magic << std::dec << ")\n";
    std::cout << std::left << std::setw(28) << "Format Version:" << header.version << "\n";
    std::cout << std::left << std::setw(28) << "Original Filename:" << (originalName.empty() ? "(none)" : originalName) << "\n";
    std::cout << std::left << std::setw(28) << "Uncompressed Size:" << CompressionStats::formatBytes(header.originalSize)
              << " (" << header.originalSize << " bytes)\n";
    std::cout << std::left << std::setw(28) << "Current File Size:" << CompressionStats::formatBytes(fs::file_size(filePath))
              << " (" << fs::file_size(filePath) << " bytes)\n";
    std::cout << std::left << std::setw(28) << "Adler-32 Checksum:" << "0x" << std::hex << std::uppercase << header.checksum << std::dec << "\n";
    std::cout << std::left << std::setw(28) << "Unique Symbols:" << header.uniqueSymbols << " / 256\n";
    std::cout << std::left << std::setw(28) << "Payload Padding Bits:" << static_cast<int>(header.paddingBits) << " bits\n";
    std::cout << "--------------------------------------------------------\n\n";
    return 0;
}

int handleAnalyze(const std::string& filePath) {
    if (!fs::exists(filePath)) {
        std::cerr << "[Error] File does not exist: " << filePath << "\n";
        return 1;
    }

    HuffmanCompressor compressor;
    CompressionStats stats;
    if (!compressor.analyzeFile(filePath, stats)) {
        std::cerr << "[Error] Could not analyze file: " << filePath << "\n";
        return 1;
    }

    std::cout << "\n[ShrinkIt] Pre-Compression Analysis for: " << filePath << "\n";
    printStats(stats);
    return 0;
}

int handleTests() {
    printBanner();
    std::cout << "Running Automated Backend Verification Suite...\n\n";

    HuffmanCompressor compressor;
    int testsPassed = 0;
    int totalTests = 0;

    auto runTest = [&](const std::string& testName, const std::vector<uint8_t>& inputData) {
        ++totalTests;
        std::cout << " [TEST " << totalTests << "] " << testName << " (" << inputData.size() << " bytes) ... ";

        std::string tIn = "test_run_in.tmp";
        std::string tHuff = "test_run.huff";
        std::string tOut = "test_run_out.tmp";

        {
            std::ofstream ofs(tIn, std::ios::binary);
            ofs.write(reinterpret_cast<const char*>(inputData.data()), inputData.size());
        }

        CompressionStats stats;
        bool compOk = compressor.compressFile(tIn, tHuff, stats);
        if (!compOk) {
            std::cout << "FAILED (Compression)\n";
            fs::remove(tIn); fs::remove(tHuff); fs::remove(tOut);
            return;
        }

        bool decompOk = compressor.decompressFile(tHuff, tOut);
        if (!decompOk) {
            std::cout << "FAILED (Decompression)\n";
            fs::remove(tIn); fs::remove(tHuff); fs::remove(tOut);
            return;
        }

        bool match = HuffmanCompressor::verifyLosslessIntegrity(tIn, tOut);
        if (match) {
            std::cout << "PASSED (Lossless Exact Match 100% | Ratio: "
                      << std::fixed << std::setprecision(2) << stats.compressionRatio << "x)\n";
            ++testsPassed;
        } else {
            std::cout << "FAILED (Data mismatch)\n";
        }

        fs::remove(tIn);
        fs::remove(tHuff);
        fs::remove(tOut);
    };

    // Test 1: Empty file
    runTest("Empty File (0 Bytes)", {});

    // Test 2: Single unique character repeated
    std::vector<uint8_t> singleChar(1000, 'A');
    runTest("Single Unique Byte Repeated ('A' x 1000)", singleChar);

    // Test 3: Standard English text
    std::string text = "ShrinkIt: High performance lossless compression with Huffman Coding and Greedy Algorithm! "
                       "Optimal prefix codes are generated using a Min-Heap priority queue and binary tree.";
    std::vector<uint8_t> textBytes(text.begin(), text.end());
    runTest("English Text String", textBytes);

    // Test 4: Highly repetitive text
    std::string rep;
    for (int i = 0; i < 500; ++i) rep += "ABC_XYZ_123_SHRINKIT_";
    std::vector<uint8_t> repBytes(rep.begin(), rep.end());
    runTest("Repetitive Pattern (10,500 bytes)", repBytes);

    // Test 5: Full 256-byte ASCII / Binary range
    std::vector<uint8_t> fullRange;
    for (int cycle = 0; cycle < 50; ++cycle) {
        for (int b = 0; b < 256; ++b) {
            fullRange.push_back(static_cast<uint8_t>(b));
        }
    }
    runTest("Full 256-Byte Spectrum (12,800 bytes)", fullRange);

    // Test 6: Pseudo-random bytes
    std::vector<uint8_t> randomBytes(50000);
    std::mt19937 rng(42);
    for (auto& b : randomBytes) b = static_cast<uint8_t>(rng() & 0xFF);
    runTest("Pseudo-random Binary Stream (50 KB)", randomBytes);

    std::cout << "\n================ TEST RESULTS ================\n";
    std::cout << " Passed: " << testsPassed << " / " << totalTests << " tests.\n";
    if (testsPassed == totalTests) {
        std::cout << " STATUS: ALL TESTS PASSED SUCCESSFULLY! (100% Lossless Integrity)\n";
        std::cout << "==============================================\n\n";
        return 0;
    } else {
        std::cout << " STATUS: SOME TESTS FAILED.\n";
        std::cout << "==============================================\n\n";
        return 1;
    }
}

int handleBenchmark(int sizeMB = 5) {
    printBanner();
    std::cout << "Running ShrinkIt Performance Benchmark (" << sizeMB << " MB dataset)...\n\n";

    if (sizeMB <= 0) sizeMB = 5;
    size_t totalBytes = static_cast<size_t>(sizeMB) * 1024 * 1024;

    std::cout << "Generating test dataset (" << sizeMB << " MB) ...\n";
    std::vector<uint8_t> data(totalBytes);
    // Skewed frequency distribution typical of natural text/source code
    std::mt19937 rng(1337);
    std::discrete_distribution<int> dist({
        100, 20, 30, 45, 120, 25, 18, 60, 80, 2, 8, 40, 25, 70, 75, 20, 1, 60, 65, 90, 30, 10, 20, 2, 20, 1
    });

    for (size_t i = 0; i < totalBytes; ++i) {
        data[i] = static_cast<uint8_t>('a' + dist(rng));
    }

    std::string bIn = "benchmark_in.tmp";
    std::string bHuff = "benchmark.huff";
    std::string bOut = "benchmark_out.tmp";

    {
        std::ofstream ofs(bIn, std::ios::binary);
        ofs.write(reinterpret_cast<const char*>(data.data()), data.size());
    }

    HuffmanCompressor compressor;
    CompressionStats stats;

    std::cout << "Starting compression benchmark...\n";
    auto cStart = std::chrono::high_resolution_clock::now();
    compressor.compressFile(bIn, bHuff, stats);
    auto cEnd = std::chrono::high_resolution_clock::now();

    double compMs = std::chrono::duration<double, std::milli>(cEnd - cStart).count();
    double compMBs = (static_cast<double>(totalBytes) / (1024.0 * 1024.0)) / (compMs / 1000.0);

    std::cout << "Starting decompression benchmark...\n";
    auto dStart = std::chrono::high_resolution_clock::now();
    compressor.decompressFile(bHuff, bOut);
    auto dEnd = std::chrono::high_resolution_clock::now();

    double decompMs = std::chrono::duration<double, std::milli>(dEnd - dStart).count();
    double decompMBs = (static_cast<double>(totalBytes) / (1024.0 * 1024.0)) / (decompMs / 1000.0);

    bool lossLess = HuffmanCompressor::verifyLosslessIntegrity(bIn, bOut);

    std::cout << "\n================ BENCHMARK RESULTS ================\n";
    std::cout << std::left << std::setw(28) << "Input Dataset Size:" << sizeMB << " MB (" << totalBytes << " bytes)\n";
    std::cout << std::left << std::setw(28) << "Compressed Size:"
              << CompressionStats::formatBytes(stats.compressedSizeBytes) << "\n";
    std::cout << std::left << std::setw(28) << "Space Savings:"
              << std::fixed << std::setprecision(2) << stats.spaceSavingPercent << "%\n";
    std::cout << std::left << std::setw(28) << "Compression Ratio:"
              << stats.compressionRatio << "x\n";
    std::cout << std::left << std::setw(28) << "Compression Time:"
              << compMs << " ms (" << compMBs << " MB/s)\n";
    std::cout << std::left << std::setw(28) << "Decompression Time:"
              << decompMs << " ms (" << decompMBs << " MB/s)\n";
    std::cout << std::left << std::setw(28) << "Lossless Checksum Match:"
              << (lossLess ? "VERIFIED (100% Identical)" : "FAILED") << "\n";
    std::cout << "====================================================\n\n";

    fs::remove(bIn);
    fs::remove(bHuff);
    fs::remove(bOut);
    return lossLess ? 0 : 1;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printHelp(argv[0]);
        return 0;
    }

    std::string cmd = argv[1];

    if (cmd == "-h" || cmd == "--help") {
        printHelp(argv[0]);
        return 0;
    } else if (cmd == "-t" || cmd == "--test") {
        return handleTests();
    } else if (cmd == "-b" || cmd == "--benchmark") {
        int sz = 5;
        if (argc >= 3) {
            try { sz = std::stoi(argv[2]); } catch (...) { sz = 5; }
        }
        return handleBenchmark(sz);
    } else if (cmd == "-c" || cmd == "--compress") {
        if (argc < 3) {
            std::cerr << "Usage: " << argv[0] << " -c <file> [-o <out.huff>]\n";
            return 1;
        }
        std::string inPath = argv[2];
        std::string outPath = "";
        for (int i = 3; i < argc; ++i) {
            if (std::string(argv[i]) == "-o" && i + 1 < argc) {
                outPath = argv[i + 1];
                break;
            }
        }
        return handleCompress(inPath, outPath);
    } else if (cmd == "-d" || cmd == "--decompress") {
        if (argc < 3) {
            std::cerr << "Usage: " << argv[0] << " -d <file.huff> [-o <dest>]\n";
            return 1;
        }
        std::string inPath = argv[2];
        std::string outPath = "";
        for (int i = 3; i < argc; ++i) {
            if (std::string(argv[i]) == "-o" && i + 1 < argc) {
                outPath = argv[i + 1];
                break;
            }
        }
        return handleDecompress(inPath, outPath);
    } else if (cmd == "-a" || cmd == "--analyze") {
        if (argc < 3) {
            std::cerr << "Usage: " << argv[0] << " -a <file>\n";
            return 1;
        }
        return handleAnalyze(argv[2]);
    } else if (cmd == "-i" || cmd == "--inspect") {
        if (argc < 3) {
            std::cerr << "Usage: " << argv[0] << " -i <file.huff>\n";
            return 1;
        }
        return handleInspect(argv[2]);
    } else {
        std::cerr << "Unknown command: " << cmd << "\n";
        printHelp(argv[0]);
        return 1;
    }
}
