#pragma once

#include <cstdint>
#include <string>

namespace shrinkit {
namespace core {

/**
 * @brief Represents a variable-length prefix-free bit sequence assigned to a symbol.
 */
struct BitCode {
    uint64_t bits = 0;   // The bit sequence (up to 64 bits)
    uint8_t length = 0;  // Number of valid bits in the code

    BitCode() = default;
    BitCode(uint64_t b, uint8_t len) : bits(b), length(len) {}

    // Appends a 0 or 1 bit to the right
    void appendBit(uint8_t bit) {
        bits = (bits << 1) | (bit & 1);
        ++length;
    }

    // Converts the bit sequence to a human-readable string ("10101")
    [[nodiscard]] std::string toString() const {
        if (length == 0) return "";
        std::string s;
        s.reserve(length);
        for (int i = length - 1; i >= 0; --i) {
            s.push_back(((bits >> i) & 1) ? '1' : '0');
        }
        return s;
    }

    // Creates BitCode from string ("10101")
    static BitCode fromString(const std::string& str) {
        BitCode bc;
        for (char c : str) {
            bc.appendBit(c == '1' ? 1 : 0);
        }
        return bc;
    }

    bool operator==(const BitCode& other) const noexcept {
        return bits == other.bits && length == other.length;
    }
};

} // namespace core
} // namespace shrinkit
