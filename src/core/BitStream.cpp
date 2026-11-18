#include "BitStream.h"

namespace shrinkit {
namespace core {

BitWriter::BitWriter(std::ostream& out) : out_(out) {}

BitWriter::~BitWriter() {
    flush();
}

void BitWriter::writeBit(uint8_t bit) {
    buffer_ = (buffer_ << 1) | (bit & 1);
    ++bitCount_;
    ++totalBitsWritten_;

    if (bitCount_ == 8) {
        out_.put(static_cast<char>(buffer_));
        buffer_ = 0;
        bitCount_ = 0;
    }
}

void BitWriter::writeCode(const BitCode& code) {
    for (int i = code.length - 1; i >= 0; --i) {
        writeBit(static_cast<uint8_t>((code.bits >> i) & 1));
    }
}

void BitWriter::writeBits(uint64_t value, uint8_t numBits) {
    for (int i = numBits - 1; i >= 0; --i) {
        writeBit(static_cast<uint8_t>((value >> i) & 1));
    }
}

uint8_t BitWriter::flush() {
    if (bitCount_ == 0) {
        return 0;
    }

    uint8_t padding = 8 - bitCount_;
    buffer_ <<= padding;
    out_.put(static_cast<char>(buffer_));
    buffer_ = 0;
    bitCount_ = 0;
    return padding;
}

BitReader::BitReader(std::istream& in) : in_(in) {}

int BitReader::readBit() {
    if (bitPos_ == 0) {
        char ch;
        if (!in_.get(ch)) {
            eofReached_ = true;
            return -1;
        }
        buffer_ = static_cast<uint8_t>(ch);
        bitPos_ = 8;
    }

    --bitPos_;
    ++totalBitsRead_;
    return (buffer_ >> bitPos_) & 1;
}

bool BitReader::readBits(uint8_t numBits, uint64_t& outValue) {
    outValue = 0;
    for (uint8_t i = 0; i < numBits; ++i) {
        int b = readBit();
        if (b == -1) {
            return false;
        }
        outValue = (outValue << 1) | b;
    }
    return true;
}

} // namespace core
} // namespace shrinkit
