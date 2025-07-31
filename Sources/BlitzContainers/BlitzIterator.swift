/// A raw iterator over a contiguous buffer of elements.
///
/// `BlitzIterator` provides sequential access to elements stored in unmanaged memory,
/// such as in a `BlitzArray`. It avoids any overhead from ARC or standard collection
/// boxing, and assumes the buffer remains valid for the duration of iteration.
///
/// - Warning: This iterator does **not** retain ownership of the underlying buffer.
///            It is the caller’s responsibility to ensure the memory is valid
///            for the entire iteration lifecycle.
///
/// Used internally by views like `BlitzView`, or can be used directly for
/// low-level traversal of raw arrays.
///
/// - Parameters:
///   - Element: The element type being iterated over.
public struct BlitzIterator<Element>: IteratorProtocol {
    private let buffer: UnsafePointer<Element>
    private let count: Int
    private var index: Int = 0

    /// Creates an iterator over a raw buffer of elements.
    ///
    /// - Parameters:
    ///   - buffer: A pointer to the first element of a contiguous element buffer.
    ///   - count: The number of elements in the buffer.
    public init(buffer: UnsafePointer<Element>, count: Int) {
        self.buffer = buffer
        self.count = count
    }

    /// Returns the next element in the sequence, or `nil` if iteration is complete.
    public mutating func next() -> Element? {
        guard index < count else { return nil }
        defer { index += 1 }
        return buffer[index]
    }
}