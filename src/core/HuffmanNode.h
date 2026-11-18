#pragma once

#include <cstdint>
#include <memory>
#include <string>

namespace shrinkit {
namespace core {

/**
 * @brief Represents a node in the Huffman Binary Tree.
 *
 * Implements the Binary Tree component of the Greedy Huffman Coding algorithm.
 * Leaf nodes store the character symbol and its occurrence frequency.
 * Internal nodes represent merged subtrees and store the sum of frequencies.
 */
struct HuffmanNode {
    uint8_t symbol;
    uint64_t frequency;
    std::shared_ptr<HuffmanNode> left;
    std::shared_ptr<HuffmanNode> right;

    // Constructor for leaf nodes
    HuffmanNode(uint8_t sym, uint64_t freq)
        : symbol(sym), frequency(freq), left(nullptr), right(nullptr) {}

    // Constructor for internal nodes (greedy merge of two lowest-frequency nodes)
    HuffmanNode(uint64_t freq, std::shared_ptr<HuffmanNode> l, std::shared_ptr<HuffmanNode> r)
        : symbol(0), frequency(freq), left(std::move(l)), right(std::move(r)) {}

    // Determines if the current node is a leaf in the prefix tree
    [[nodiscard]] bool isLeaf() const noexcept {
        return left == nullptr && right == nullptr;
    }
};

/**
 * @brief Comparator functor for the Min-Heap priority queue.
 *
 * The greedy strategy in Huffman Coding requires repeatedly selecting
 * the two nodes with the lowest frequencies.
 */
struct HuffmanNodeCompare {
    bool operator()(const std::shared_ptr<HuffmanNode>& lhs,
                    const std::shared_ptr<HuffmanNode>& rhs) const noexcept {
        if (lhs->frequency != rhs->frequency) {
            return lhs->frequency > rhs->frequency; // Min-heap: smaller frequency has higher priority
        }
        // Deterministic tie-breaker for identical frequencies ensures canonical tree construction
        return lhs->symbol > rhs->symbol;
    }
};

} // namespace core
} // namespace shrinkit
