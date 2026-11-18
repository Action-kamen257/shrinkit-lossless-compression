#pragma once

#include <cstdint>
#include <cstddef>

namespace shrinkit {
namespace core {

/**
 * @brief Computes Adler-32 and CRC-32 checksums for end-to-end data integrity verification.
 */
class Checksum {
public:
    // Computes Adler-32 checksum (fast and reliable)
    static uint32_t adler32(const uint8_t* data, size_t length, uint32_t init = 1) noexcept {
        constexpr uint32_t MOD_ADLER = 65521;
        uint32_t a = init & 0xFFFF;
        uint32_t b = (init >> 16) & 0xFFFF;

        for (size_t i = 0; i < length; ++i) {
            a = (a + data[i]) % MOD_ADLER;
            b = (b + a) % MOD_ADLER;
        }

        return (b << 16) | a;
    }

    // CRC-32 calculation with IEEE 802.3 polynomial
    static uint32_t crc32(const uint8_t* data, size_t length, uint32_t init = 0xFFFFFFFF) noexcept {
        uint32_t crc = init;
        for (size_t i = 0; i < length; ++i) {
            uint8_t byte = data[i];
            crc ^= byte;
            for (int j = 0; j < 8; ++j) {
                uint32_t mask = (crc & 1) ? 0xFFFFFFFF : 0;
                crc = (crc >> 1) ^ (0xEDB88320 & mask);
            }
        }
        return ~crc;
    }
};

} // namespace core
} // namespace shrinkit
