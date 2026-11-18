#pragma once

#include "BitCode.h"
#include <iostream>
#include <vector>
#include <cstdint>

namespace shrinkit {
namespace core {

/**
 * @brief Handles bit-level writing to an output stream or buffer.
 */
class BitWriter {
public:
    explicit BitWriter(std::ostream& out);
    ~BitWriter();

    // Writes a single bit (0 or 1)
    void writeBit(uint8_t bit);

    // Writes variable length bit code
    void writeCode(const BitCode& code);

    // Writes n bits from an integer value (MSB to LSB of the n bits)
    void writeBits(uint64_t value, uint8_t numBits);

    // Flushes any partially filled byte to the stream with zero-padding.
    // Returns the number of padding bits added (0 to 7).
    uint8_t flush();

    // Total number of bits written so far
    [[nodiscard]] uint64_t totalBitsWritten() const noexcept {
        return totalBitsWritten_;
    }

private:
    std::ostream& out_;
    uint8_t buffer_ = 0;       // Current byte accumulator
    uint8_t bitCount_ = 0;     // Number of valid bits in buffer_ (0 to 7)
    uint64_t totalBitsWritten_ = 0;
};

/**
 * @brief Handles bit-level reading from an input stream.
 */
class BitReader {
public:
    explicit BitReader(std::istream& in);

    // Reads a single bit. Returns 0 or 1, or -1 on EOF.
    int readBit();

    // Reads n bits into an integer. Returns true on success, false on EOF before reading all bits.
    bool readBits(uint8_t numBits, uint64_t& outValue);

    [[nodiscard]] bool isEOF() const noexcept {
        return eofReached_;
    }

    [[nodiscard]] uint64_t totalBitsRead() const noexcept {
        return totalBitsRead_;
    }

private:
    std::istream& in_;
    uint8_t buffer_ = 0;
    uint8_t bitPos_ = 0;       // Next bit index to read (0 = exhausted)
    bool eofReached_ = false;
    uint64_t totalBitsRead_ = 0;
};

} // namespace core
} // namespace shrinkit
