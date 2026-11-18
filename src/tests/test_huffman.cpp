#include "MinHeap.h"
#include "BitCode.h"
#include "BitStream.h"
#include "Checksum.h"
#include "HuffmanTree.h"
#include "HuffmanCompressor.h"
#include <iostream>
#include <fstream>
#include <cassert>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>
#include <filesystem>
#include <random>

namespace fs = std::filesystem;
using namespace shrinkit::core;

int g_passedTests = 0;
int g_totalTests = 0;

#define ASSERT_TEST(cond, msg) \
    do { \
        ++g_totalTests; \
        if (cond) { \
            std::cout << "  [PASS] " << msg << "\n"; \
            ++g_passedTests; \
        } else { \
            std::cerr << "  [FAIL] " << msg << " (Line " << __LINE__ << ")\n"; \
        } \
    } while(0)

void testMinHeap() {
    std::cout << "\n[TEST SUITE] MinHeap (Priority Queue)\n";

    MinHeap<int> heap;
    ASSERT_TEST(heap.empty(), "Heap starts empty");
    ASSERT_TEST(heap.size() == 0, "Heap size is 0");

    heap.push(50);
    heap.push(10);
    heap.push(30);
    heap.push(5);
    heap.push(40);

    ASSERT_TEST(!heap.empty(), "Heap is not empty after pushes");
    ASSERT_TEST(heap.size() == 5, "Heap size is 5");
    ASSERT_TEST(heap.top() == 5, "Root element is minimum (5)");

    std::vector<int> extracted;
    while (!heap.empty()) {
        extracted.push_back(heap.extractMin());
    }

    std::vector<int> expected = {5, 10, 30, 40, 50};
    ASSERT_TEST(extracted == expected, "Elements extracted in sorted ascending order");
    ASSERT_TEST(heap.empty(), "Heap is empty after extracting all elements");
}

void testBitStream() {
    std::cout << "\n[TEST SUITE] BitWriter and BitReader\n";

    std::stringstream ss;
    {
        BitWriter writer(ss);
        // Write pattern: 1, 0, 1, 1, 0 (5 bits)
        writer.writeBit(1);
        writer.writeBit(0);
        writer.writeBit(1);
        writer.writeBit(1);
        writer.writeBit(0);

        // Write BitCode: 0b101 (3 bits)
        BitCode bc;
        bc.appendBit(1);
        bc.appendBit(0);
        bc.appendBit(1);
        writer.writeCode(bc);
        // Total = 8 bits = 1 full byte (0b10110101 = 0xB5)
        uint8_t pad = writer.flush();
        ASSERT_TEST(pad == 0, "No padding required for exact 8-bit boundary");
    }

    {
        BitReader reader(ss);
        ASSERT_TEST(reader.readBit() == 1, "Bit 0 matches");
        ASSERT_TEST(reader.readBit() == 0, "Bit 1 matches");
        ASSERT_TEST(reader.readBit() == 1, "Bit 2 matches");
        ASSERT_TEST(reader.readBit() == 1, "Bit 3 matches");
        ASSERT_TEST(reader.readBit() == 0, "Bit 4 matches");
        ASSERT_TEST(reader.readBit() == 1, "Bit 5 matches");
        ASSERT_TEST(reader.readBit() == 0, "Bit 6 matches");
        ASSERT_TEST(reader.readBit() == 1, "Bit 7 matches");
        ASSERT_TEST(reader.readBit() == -1, "EOF reached correctly");
    }
}

void testPrefixFreeCodes() {
    std::cout << "\n[TEST SUITE] Huffman Tree & Prefix-Free Property\n";

    std::array<uint64_t, 256> freqs{};
    freqs.fill(0);
    freqs['A'] = 100;
    freqs['B'] = 50;
    freqs['C'] = 30;
    freqs['D'] = 20;
    freqs['E'] = 10;

    HuffmanTree tree;
    std::vector<AlgorithmStep> steps;
    bool ok = tree.buildFromFrequencies(freqs, &steps);
    ASSERT_TEST(ok, "Huffman tree built successfully");
    ASSERT_TEST(tree.leafCount() == 5, "Leaf count matches unique symbols");
    ASSERT_TEST(steps.size() == 4, "Greedy algorithm executed N-1 merges (4 merges)");

    auto codes = tree.generateCodes();
    ASSERT_TEST(codes.size() == 5, "All 5 symbols assigned codes");

    // Most frequent symbol ('A') must have shortest or equal code length
    ASSERT_TEST(codes['A'].length <= codes['E'].length, "Frequent symbol 'A' has shorter code than rare symbol 'E'");

    // Verify Prefix-Free Property: No code can be a prefix of another code
    bool prefixFree = true;
    for (const auto& [s1, c1] : codes) {
        std::string s1Str = c1.toString();
        for (const auto& [s2, c2] : codes) {
            if (s1 == s2) continue;
            std::string s2Str = c2.toString();
            if (s2Str.rfind(s1Str, 0) == 0) { // s1Str is a prefix of s2Str
                prefixFree = false;
                break;
            }
        }
    }
    ASSERT_TEST(prefixFree, "Prefix-Free property holds 100% across all generated codes");
}

void testChecksum() {
    std::cout << "\n[TEST SUITE] Adler-32 and CRC-32 Checksum Validation\n";

    std::string text = "ShrinkIt Lossless Integrity Check";
    auto data = reinterpret_cast<const uint8_t*>(text.data());
    uint32_t a1 = Checksum::adler32(data, text.size());
    uint32_t a2 = Checksum::adler32(data, text.size());
    ASSERT_TEST(a1 == a2 && a1 != 0, "Adler-32 is deterministic and non-zero");

    std::string textModified = "ShrinkIt Lossless Integrity Check!";
    auto dataMod = reinterpret_cast<const uint8_t*>(textModified.data());
    uint32_t a3 = Checksum::adler32(dataMod, textModified.size());
    ASSERT_TEST(a1 != a3, "Adler-32 detects single character perturbation");
}

void testEndToEndCompression() {
    std::cout << "\n[TEST SUITE] End-to-End Compression & Decompression\n";

    HuffmanCompressor compressor;

    auto testRoundTrip = [&](const std::string& name, const std::string& content) {
        std::string fIn = "test_e2e_" + name + ".tmp";
        std::string fHuff = "test_e2e_" + name + ".huff";
        std::string fOut = "test_e2e_" + name + "_out.tmp";

        {
            std::ofstream ofs(fIn, std::ios::binary);
            ofs.write(content.data(), content.size());
        }

        CompressionStats stats;
        bool cOk = compressor.compressFile(fIn, fHuff, stats);
        ASSERT_TEST(cOk, name + ": Compression succeeded");

        bool dOk = compressor.decompressFile(fHuff, fOut);
        ASSERT_TEST(dOk, name + ": Decompression succeeded");

        bool identical = HuffmanCompressor::verifyLosslessIntegrity(fIn, fOut);
        ASSERT_TEST(identical, name + ": 100% Byte-for-byte identical output");

        fs::remove(fIn);
        fs::remove(fHuff);
        fs::remove(fOut);
    };

    testRoundTrip("empty", "");
    testRoundTrip("single_char", std::string(5000, 'Z'));
    testRoundTrip("pangram", "The quick brown fox jumps over the lazy dog repeatedly and efficiently!");
    
    std::string repeated;
    for (int i = 0; i < 200; ++i) repeated += "SHRINKIT_HUFFMAN_GREEDY_ALGORITHM_2026_";
    testRoundTrip("repetitive", repeated);
}

void testErrorHandling() {
    std::cout << "\n[TEST SUITE] Error Handling & Corrupted File Detection\n";

    HuffmanCompressor compressor;
    CompressionStats stats;

    bool threwOnMissing = false;
    try {
        compressor.compressFile("non_existent_file_xyz_123.bin", "out.huff", stats);
    } catch (...) {
        threwOnMissing = true;
    }
    ASSERT_TEST(threwOnMissing, "Properly throws on missing source file");

    // Create a corrupted .huff file (bad magic)
    {
        std::ofstream ofs("corrupted.huff", std::ios::binary);
        uint32_t badMagic = 0xDEADBEEF;
        ofs.write(reinterpret_cast<const char*>(&badMagic), sizeof(badMagic));
    }

    bool threwOnBadMagic = false;
    try {
        compressor.decompressFile("corrupted.huff", "out.bin");
    } catch (const std::runtime_error& e) {
        threwOnBadMagic = true;
    }
    ASSERT_TEST(threwOnBadMagic, "Detects invalid magic identifier in corrupted file");
    fs::remove("corrupted.huff");
}

int main() {
    std::cout << "========================================================\n";
    std::cout << "       SHRINKIT CORE UNIT TEST SUITE (C++17)           \n";
    std::cout << "========================================================\n";

    testMinHeap();
    testBitStream();
    testPrefixFreeCodes();
    testChecksum();
    testEndToEndCompression();
    testErrorHandling();

    std::cout << "\n========================================================\n";
    std::cout << " TEST SUMMARY: " << g_passedTests << " / " << g_totalTests << " passed.\n";
    if (g_passedTests == g_totalTests) {
        std::cout << " STATUS: ALL UNIT TESTS PASSED WITH ZERO ERRORS.\n";
        std::cout << "========================================================\n\n";
        return 0;
    } else {
        std::cerr << " STATUS: SOME UNIT TESTS FAILED.\n";
        std::cout << "========================================================\n\n";
        return 1;
    }
}
