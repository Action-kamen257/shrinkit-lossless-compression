#include "HuffmanTree.h"
#include <algorithm>
#include <cmath>
#include <iomanip>
#include <sstream>

namespace shrinkit {
namespace core {

bool HuffmanTree::buildFromFrequencies(const std::array<uint64_t, 256>& frequencies,
                                       std::vector<AlgorithmStep>* outGreedySteps) {
    clear();

    if (outGreedySteps) {
        outGreedySteps->clear();
    }

    MinHeap<std::shared_ptr<HuffmanNode>, HuffmanNodeCompare> minHeap;

    for (size_t i = 0; i < 256; ++i) {
        if (frequencies[i] > 0) {
            auto node = std::make_shared<HuffmanNode>(static_cast<uint8_t>(i), frequencies[i]);
            minHeap.push(node);
            ++leafCount_;
            totalFrequency_ += frequencies[i];
        }
    }

    if (leafCount_ == 0) {
        root_ = nullptr;
        return true;
    }

    // Edge case: single unique byte
    if (leafCount_ == 1) {
        auto singleLeaf = minHeap.extractMin();
        root_ = std::make_shared<HuffmanNode>(singleLeaf->frequency, singleLeaf, nullptr);
        if (outGreedySteps) {
            AlgorithmStep step;
            step.stepNumber = 1;
            step.mergedFrequency = root_->frequency;
            step.description = "Single unique symbol root wrapper created";
            step.leftChildDesc = "Byte 0x" + [] (uint8_t b) {
                std::ostringstream ss;
                ss << std::hex << std::uppercase << std::setw(2) << std::setfill('0') << static_cast<int>(b);
                return ss.str();
            }(singleLeaf->symbol);
            step.rightChildDesc = "None";
            outGreedySteps->push_back(step);
        }
        return true;
    }

    // Core Greedy Huffman merges
    size_t stepCounter = 1;
    while (minHeap.size() > 1) {
        auto left = minHeap.extractMin();
        auto right = minHeap.extractMin();

        uint64_t sumFreq = left->frequency + right->frequency;
        auto parent = std::make_shared<HuffmanNode>(sumFreq, left, right);

        if (outGreedySteps) {
            AlgorithmStep step;
            step.stepNumber = stepCounter++;
            step.mergedFrequency = sumFreq;

            auto nodeDesc = [](const std::shared_ptr<HuffmanNode>& n) -> std::string {
                std::ostringstream ss;
                if (n->isLeaf()) {
                    char c = static_cast<char>(n->symbol);
                    if (c >= 32 && c <= 126) {
                        ss << "'" << c << "' (freq: " << n->frequency << ")";
                    } else {
                        ss << "0x" << std::hex << std::uppercase << std::setw(2) << std::setfill('0')
                           << static_cast<int>(n->symbol) << " (freq: " << std::dec << n->frequency << ")";
                    }
                } else {
                    ss << "Internal (freq: " << n->frequency << ")";
                }
                return ss.str();
            };

            step.leftChildDesc = nodeDesc(left);
            step.rightChildDesc = nodeDesc(right);
            step.description = "Greedy merge of " + step.leftChildDesc + " and " + step.rightChildDesc;
            outGreedySteps->push_back(step);
        }

        minHeap.push(parent);
    }

    root_ = minHeap.extractMin();
    return true;
}

std::unordered_map<uint8_t, BitCode> HuffmanTree::generateCodes() const {
    std::unordered_map<uint8_t, BitCode> codes;
    if (!root_) return codes;

    if (root_->isLeaf()) {
        BitCode code;
        code.appendBit(0);
        codes[root_->symbol] = code;
        return codes;
    }

    BitCode initialCode;
    generateCodesDFS(root_, initialCode, codes);
    return codes;
}

void HuffmanTree::generateCodesDFS(const std::shared_ptr<HuffmanNode>& node,
                                  BitCode currentCode,
                                  std::unordered_map<uint8_t, BitCode>& outCodes) const {
    if (!node) return;

    if (node->isLeaf()) {
        outCodes[node->symbol] = currentCode;
        return;
    }

    if (node->left) {
        BitCode leftCode = currentCode;
        leftCode.appendBit(0);
        generateCodesDFS(node->left, leftCode, outCodes);
    }

    if (node->right) {
        BitCode rightCode = currentCode;
        rightCode.appendBit(1);
        generateCodesDFS(node->right, rightCode, outCodes);
    }
}

void HuffmanTree::serializeTree(BitWriter& writer) const {
    if (!root_) return;
    serializeNode(root_, writer);
}

void HuffmanTree::serializeNode(const std::shared_ptr<HuffmanNode>& node, BitWriter& writer) {
    if (!node) return;

    if (node->isLeaf()) {
        writer.writeBit(1);
        writer.writeBits(node->symbol, 8);
    } else {
        writer.writeBit(0);
        serializeNode(node->left, writer);
        serializeNode(node->right, writer);
    }
}

std::shared_ptr<HuffmanNode> HuffmanTree::deserializeTree(BitReader& reader) {
    return deserializeNode(reader);
}

std::shared_ptr<HuffmanNode> HuffmanTree::deserializeNode(BitReader& reader) {
    int bit = reader.readBit();
    if (bit == -1) return nullptr;

    if (bit == 1) {
        // Leaf node: read 8-bit symbol
        uint64_t sym = 0;
        if (!reader.readBits(8, sym)) return nullptr;
        return std::make_shared<HuffmanNode>(static_cast<uint8_t>(sym), 0);
    } else {
        // Internal node: recursively read left and right subtrees
        auto left = deserializeNode(reader);
        auto right = deserializeNode(reader);
        return std::make_shared<HuffmanNode>(0, left, right);
    }
}

size_t HuffmanTree::countLeaves(const std::shared_ptr<HuffmanNode>& node) {
    if (!node) return 0;
    if (node->isLeaf()) return 1;
    return countLeaves(node->left) + countLeaves(node->right);
}

size_t HuffmanTree::height() const {
    return calculateHeight(root_);
}

size_t HuffmanTree::calculateHeight(const std::shared_ptr<HuffmanNode>& node) {
    if (!node) return 0;
    if (node->isLeaf()) return 1;
    size_t leftH = calculateHeight(node->left);
    size_t rightH = calculateHeight(node->right);
    return 1 + std::max(leftH, rightH);
}

double HuffmanTree::calculateEntropy(const std::array<uint64_t, 256>& frequencies) const {
    if (totalFrequency_ == 0) return 0.0;
    double entropy = 0.0;
    double total = static_cast<double>(totalFrequency_);

    for (size_t i = 0; i < 256; ++i) {
        if (frequencies[i] > 0) {
            double p = static_cast<double>(frequencies[i]) / total;
            entropy -= p * (std::log(p) / std::log(2.0));
        }
    }
    return entropy;
}

double HuffmanTree::calculateAverageCodeLength(const std::array<uint64_t, 256>& frequencies,
                                              const std::unordered_map<uint8_t, BitCode>& codes) const {
    if (totalFrequency_ == 0) return 0.0;
    double totalWeightedBits = 0.0;
    double total = static_cast<double>(totalFrequency_);

    for (size_t i = 0; i < 256; ++i) {
        if (frequencies[i] > 0) {
            auto it = codes.find(static_cast<uint8_t>(i));
            if (it != codes.end()) {
                totalWeightedBits += static_cast<double>(frequencies[i]) * it->second.length;
            }
        }
    }
    return totalWeightedBits / total;
}

void HuffmanTree::clear() noexcept {
    root_ = nullptr;
    leafCount_ = 0;
    totalFrequency_ = 0;
}

} // namespace core
} // namespace shrinkit
