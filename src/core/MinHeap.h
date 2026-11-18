#pragma once

#include <vector>
#include <functional>
#include <stdexcept>
#include <utility>

namespace shrinkit {
namespace core {

/**
 * @brief Generic Min Heap (Priority Queue) implementation.
 *
 * Fundamental data structure for the Greedy Huffman Algorithm.
 * Maintained as a complete binary tree inside a dynamic array (std::vector).
 *
 * Time Complexities:
 *   - Insertion (push): O(log N)
 *   - Extraction (pop / extractMin): O(log N)
 *   - Peek (top): O(1)
 *   - Heapify: O(N)
 */
template <typename T, typename Compare = std::greater<T>>
class MinHeap {
public:
    explicit MinHeap(Compare comp = Compare()) : comparator_(comp) {}

    template <typename InputIterator>
    MinHeap(InputIterator first, InputIterator last, Compare comp = Compare())
        : comparator_(comp), data_(first, last) {
        buildHeap();
    }

    // Inserts a new element into the min-heap and restores the heap property via bubble-up.
    void push(const T& value) {
        data_.push_back(value);
        siftUp(data_.size() - 1);
    }

    void push(T&& value) {
        data_.push_back(std::move(value));
        siftUp(data_.size() - 1);
    }

    // Returns a reference to the minimum element (root of the heap).
    [[nodiscard]] const T& top() const {
        if (data_.empty()) {
            throw std::out_of_range("MinHeap::top() called on an empty heap.");
        }
        return data_.front();
    }

    // Removes the minimum element from the root and restores heap property via bubble-down.
    void pop() {
        if (data_.empty()) {
            throw std::out_of_range("MinHeap::pop() called on an empty heap.");
        }
        data_[0] = std::move(data_.back());
        data_.pop_back();
        if (!data_.empty()) {
            siftDown(0);
        }
    }

    // Extracts and returns the minimum element.
    T extractMin() {
        if (data_.empty()) {
            throw std::out_of_range("MinHeap::extractMin() called on an empty heap.");
        }
        T minValue = std::move(data_[0]);
        data_[0] = std::move(data_.back());
        data_.pop_back();
        if (!data_.empty()) {
            siftDown(0);
        }
        return minValue;
    }

    [[nodiscard]] size_t size() const noexcept {
        return data_.size();
    }

    [[nodiscard]] bool empty() const noexcept {
        return data_.empty();
    }

    void clear() noexcept {
        data_.clear();
    }

    // Access to underlying array for inspection / visualization
    [[nodiscard]] const std::vector<T>& elements() const noexcept {
        return data_;
    }

private:
    std::vector<T> data_;
    Compare comparator_;

    static constexpr size_t parentIndex(size_t i) noexcept {
        return (i - 1) / 2;
    }

    static constexpr size_t leftChildIndex(size_t i) noexcept {
        return 2 * i + 1;
    }

    static constexpr size_t rightChildIndex(size_t i) noexcept {
        return 2 * i + 2;
    }

    // Restores heap invariant upwards after insertion
    void siftUp(size_t index) {
        while (index > 0) {
            size_t pIndex = parentIndex(index);
            // comparator_(a, b) == true means a has lower priority than b
            // For min-heap using std::greater, comparator_(parent, child) is true when parent > child
            if (comparator_(data_[pIndex], data_[index])) {
                std::swap(data_[index], data_[pIndex]);
                index = pIndex;
            } else {
                break;
            }
        }
    }

    // Restores heap invariant downwards after root removal (Heapify)
    void siftDown(size_t index) {
        size_t n = data_.size();
        while (true) {
            size_t smallest = index;
            size_t left = leftChildIndex(index);
            size_t right = rightChildIndex(index);

            if (left < n && comparator_(data_[smallest], data_[left])) {
                smallest = left;
            }
            if (right < n && comparator_(data_[smallest], data_[right])) {
                smallest = right;
            }

            if (smallest != index) {
                std::swap(data_[index], data_[smallest]);
                index = smallest;
            } else {
                break;
            }
        }
    }

    // Linear time O(N) heap construction
    void buildHeap() {
        if (data_.empty()) return;
        for (int64_t i = static_cast<int64_t>(data_.size() / 2) - 1; i >= 0; --i) {
            siftDown(static_cast<size_t>(i));
        }
    }
};

} // namespace core
} // namespace shrinkit
