#pragma once

#include "HuffmanNode.h"
#include "MinHeap.h"
#include "BitCode.h"
#include "BitStream.h"
#include "CompressionStats.h"
#include <array>
#include <unordered_map>
#include <vector>
#include <memory>
#include <string>

namespace shrinkit {
namespace core {

/**
 * @brief Manages construction, traversal, serialization, and code generation for the Huffman Binary Tree.
 *
 * Implements the core Greedy Algorithm for prefix-free optimal binary encoding.
 */
class HuffmanTree {
public:
    HuffmanTree() = default;
    ~HuffmanTree() = default;

    // Builds the optimal Huffman tree from a 256-element byte frequency array using the Greedy Strategy.
    bool buildFromFrequencies(const std::array<uint64_t, 256>& frequencies,
                             std::vector<AlgorithmStep>* outGreedySteps = nullptr);

    // Generates the prefix-free bit codes for each leaf symbol via DFS.
    [[nodiscard]] std::unordered_map<uint8_t, BitCode> generateCodes() const;

    // Serializes the tree topology and leaf symbols into a compact bitstream (1 bit per internal, 1+8 bits per leaf)
    void serializeTree(BitWriter& writer) const;

    // Reconstructs the binary tree directly from a serialized bitstream
    static std::shared_ptr<HuffmanNode> deserializeTree(BitReader& reader);

    // Sets the root of the tree directly (used during deserialization)
    void setRoot(std::shared_ptr<HuffmanNode> r) noexcept {
        root_ = std::move(r);
        leafCount_ = countLeaves(root_);
    }

    // Returns the root of the binary tree
    [[nodiscard]] std::shared_ptr<HuffmanNode> root() const noexcept {
        return root_;
    }

    // Tree analysis metrics
    [[nodiscard]] size_t height() const;
    [[nodiscard]] size_t leafCount() const noexcept { return leafCount_; }
    [[nodiscard]] uint64_t totalFrequency() const noexcept { return totalFrequency_; }

    // Information theory calculations
    [[nodiscard]] double calculateEntropy(const std::array<uint64_t, 256>& frequencies) const;
    [[nodiscard]] double calculateAverageCodeLength(const std::array<uint64_t, 256>& frequencies,
                                                    const std::unordered_map<uint8_t, BitCode>& codes) const;

    // Resets the tree
    void clear() noexcept;

private:
    std::shared_ptr<HuffmanNode> root_ = nullptr;
    size_t leafCount_ = 0;
    uint64_t totalFrequency_ = 0;

    void generateCodesDFS(const std::shared_ptr<HuffmanNode>& node,
                          BitCode currentCode,
                          std::unordered_map<uint8_t, BitCode>& outCodes) const;

    static size_t calculateHeight(const std::shared_ptr<HuffmanNode>& node);
    static size_t countLeaves(const std::shared_ptr<HuffmanNode>& node);
    static void serializeNode(const std::shared_ptr<HuffmanNode>& node, BitWriter& writer);
    static std::shared_ptr<HuffmanNode> deserializeNode(BitReader& reader);
};

} // namespace core
} // namespace shrinkit
