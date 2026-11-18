#pragma once

#include <cstdint>

namespace shrinkit {
namespace core {

constexpr uint32_t HUFF_MAGIC = 0x48554646; // 'HUFF' in big-endian ASCII
constexpr uint16_t HUFF_VERSION = 2;        // Version 2: Compact Tree + LZ77/Huffman pipeline

enum HuffFlags : uint16_t {
    FLAG_HAS_CHECKSUM    = 1 << 0,
    FLAG_HAS_FILENAME    = 1 << 1,
    FLAG_METHOD_LZ_HUFF  = 1 << 2, // Hybrid LZ77 + Greedy Huffman (Deflate-style)
    FLAG_METHOD_RAW_HUFF = 1 << 3, // Pure Huffman Prefix Tree
    FLAG_METHOD_STORED   = 1 << 4  // Stored mode for incompressible data
};

#pragma pack(push, 1)
struct HuffHeader {
    uint32_t magic = HUFF_MAGIC;
    uint16_t version = HUFF_VERSION;
    uint16_t flags = FLAG_HAS_CHECKSUM | FLAG_HAS_FILENAME | FLAG_METHOD_LZ_HUFF;
    uint64_t originalSize = 0;           // Original uncompressed byte count
    uint32_t checksum = 0;               // Adler-32 of uncompressed data
    uint16_t fileNameLength = 0;         // Length of original filename
    uint16_t uniqueSymbols = 0;          // Number of unique symbols
    uint8_t paddingBits = 0;             // Padding bits in final byte (0 to 7)
};
#pragma pack(pop)

} // namespace core
} // namespace shrinkit
