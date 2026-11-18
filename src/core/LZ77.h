#pragma once

#include <cstdint>
#include <vector>
#include <cstddef>
#include <cstring>
#include <algorithm>

namespace shrinkit {
namespace core {

/**
 * @brief High-efficiency LZ77 sliding window dictionary encoder & decoder.
 *
 * Implements sliding window string matching (Greedy longest match).
 * When paired with Huffman Coding, this forms the foundation of DEFLATE,
 * the gold standard for lossless compression.
 */
class LZ77 {
public:
    static constexpr size_t WINDOW_SIZE = 32768; // 32 KB sliding window
    static constexpr size_t MIN_MATCH   = 3;     // Minimum match length to be worthwhile
    static constexpr size_t MAX_MATCH   = 258;   // Maximum match length
    static constexpr size_t HASH_SIZE   = 32768; // Hash table size for O(1) match lookups

    /**
     * @brief Encodes raw data into an LZ77 token stream.
     *
     * Format of token stream:
     * - Control byte: contains 8 flag bits (0 = literal byte follows, 1 = (distance, length) match follows)
     * - If literal: 1 byte literal
     * - If match: 2 bytes distance (1 to 32768) + 1 byte (length - MIN_MATCH)
     */
    static std::vector<uint8_t> compress(const uint8_t* data, size_t size) {
        if (size == 0) return {};

        std::vector<uint8_t> output;
        output.reserve(size);

        // Hash table mapping 3-byte prefix to position in input data
        std::vector<int32_t> head(HASH_SIZE, -1);
        std::vector<int32_t> prev(size, -1);

        size_t cursor = 0;

        while (cursor < size) {
            // Reserve position for control flag byte
            size_t flagPos = output.size();
            output.push_back(0);
            uint8_t flagByte = 0;

            for (uint8_t bit = 0; bit < 8 && cursor < size; ++bit) {
                size_t bestLength = 0;
                size_t bestDistance = 0;

                if (cursor + MIN_MATCH <= size) {
                    uint32_t h = hash3(data + cursor);
                    int32_t matchPos = head[h];
                    size_t chainLen = 0;
                    constexpr size_t MAX_CHAIN = 64; // Max hash chain search depth for speed

                    while (matchPos != -1 && chainLen++ < MAX_CHAIN) {
                        size_t dist = cursor - static_cast<size_t>(matchPos);
                        if (dist > WINDOW_SIZE || dist == 0) break;

                        // Count matching bytes
                        size_t maxLen = std::min<size_t>(MAX_MATCH, size - cursor);
                        size_t len = 0;
                        while (len < maxLen && data[cursor + len] == data[matchPos + len]) {
                            ++len;
                        }

                        if (len > bestLength) {
                            bestLength = len;
                            bestDistance = dist;
                            if (len >= MAX_MATCH) break;
                        }

                        matchPos = prev[matchPos];
                    }
                }

                if (bestLength >= MIN_MATCH) {
                    // Match found: set flag bit to 1
                    flagByte |= (1 << bit);

                    // Output distance (2 bytes) and length (1 byte)
                    uint16_t dist16 = static_cast<uint16_t>(bestDistance);
                    output.push_back(static_cast<uint8_t>(dist16 & 0xFF));
                    output.push_back(static_cast<uint8_t>((dist16 >> 8) & 0xFF));
                    output.push_back(static_cast<uint8_t>(bestLength - MIN_MATCH));

                    // Update hash table for matched region
                    for (size_t i = 0; i < bestLength; ++i) {
                        if (cursor + i + MIN_MATCH <= size) {
                            uint32_t h = hash3(data + cursor + i);
                            prev[cursor + i] = head[h];
                            head[h] = static_cast<int32_t>(cursor + i);
                        }
                    }
                    cursor += bestLength;
                } else {
                    // Literal byte: flag bit is 0
                    output.push_back(data[cursor]);

                    if (cursor + MIN_MATCH <= size) {
                        uint32_t h = hash3(data + cursor);
                        prev[cursor] = head[h];
                        head[h] = static_cast<int32_t>(cursor);
                    }
                    ++cursor;
                }
            }

            output[flagPos] = flagByte;
        }

        return output;
    }

    /**
     * @brief Decompresses an LZ77 token stream back to original raw bytes.
     */
    static bool decompress(const uint8_t* inData, size_t inSize, std::vector<uint8_t>& outData, size_t expectedOriginalSize) {
        outData.clear();
        outData.reserve(expectedOriginalSize);

        size_t inPos = 0;

        while (inPos < inSize && outData.size() < expectedOriginalSize) {
            uint8_t flagByte = inData[inPos++];

            for (uint8_t bit = 0; bit < 8 && inPos < inSize && outData.size() < expectedOriginalSize; ++bit) {
                bool isMatch = (flagByte & (1 << bit)) != 0;

                if (!isMatch) {
                    // Literal byte
                    outData.push_back(inData[inPos++]);
                } else {
                    // Match (distance: 2 bytes, length: 1 byte)
                    if (inPos + 3 > inSize) return false;

                    uint16_t dist = static_cast<uint16_t>(inData[inPos]) |
                                    (static_cast<uint16_t>(inData[inPos + 1]) << 8);
                    size_t len = static_cast<size_t>(inData[inPos + 2]) + MIN_MATCH;
                    inPos += 3;

                    if (dist == 0 || dist > outData.size()) return false;

                    size_t matchSrc = outData.size() - dist;
                    for (size_t i = 0; i < len && outData.size() < expectedOriginalSize; ++i) {
                        outData.push_back(outData[matchSrc + i]);
                    }
                }
            }
        }

        return outData.size() == expectedOriginalSize;
    }

private:
    static inline uint32_t hash3(const uint8_t* p) noexcept {
        return ((static_cast<uint32_t>(p[0]) << 10) ^
                (static_cast<uint32_t>(p[1]) << 5)  ^
                static_cast<uint32_t>(p[2])) & (HASH_SIZE - 1);
    }
};

} // namespace core
} // namespace shrinkit
