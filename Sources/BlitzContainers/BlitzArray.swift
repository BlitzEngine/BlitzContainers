/// A manually-managed array backed by a custom allocator.
///
/// `BlitzArray` is a value type similar to Swift’s `Array`, but with full control over
/// memory layout, growth, and lifetime.
///
/// Memory is allocated using a user-provided `BlitzAllocator`, allowing for arena/bump
/// allocation, per-frame allocators, or custom memory pools.
///
/// - Parameters:
///   - Element: The type of values stored in the array.
///   - Alloc: The allocator type used to back the array’s memory. Must conform to `BlitzAllocator`.
///
/// - Note: `BlitzArray` is `~Copyable`. Copying is not supported to prevent accidental
///         memory duplication and to preserve performance characteristics.
public struct BlitzArray<Element, Alloc: BlitzAllocator>: ~Copyable {
    public typealias Index = Int
    public private(set) var count: Int = 0

    private var capacity: Int
    private var allocator: Alloc
    @usableFromInline
    internal var buffer: UnsafeMutablePointer<Element>

    /// Creates an array with an initial capacity and an allocator.
    ///
    /// - Parameters:
    ///   - capacity: The number of elements which to allocate memory for.
    ///   - with allocator: The allocator to be used.
    public init(capacity: Int = 4, with allocator: Alloc) {
        let capacity = Swift.max(1, capacity)
        let size = capacity * MemoryLayout<Element>.stride
        let rawPtr = allocator.allocate(size: size, with: MemoryLayout<Element>.alignment, and: 0)
        let typedPtr = rawPtr.bindMemory(to: Element.self, capacity: capacity)

        self.capacity = capacity
        self.allocator = allocator
        self.buffer = typedPtr
    }

    /// Appends a new element at the end of the array
    /// - Parameter value: The element to append
    public mutating func append(_ value: Element) {
        if count == capacity {
            grow()
        }
        (buffer + count).initialize(to: value)
        count += 1
    }

    // MARK: - Collection conformance

    public var startIndex: Int { 0 }
    public var endIndex: Int { count }

    public subscript(position: Int) -> Element {
        get {
            precondition(position >= 0 && position < count, "Index out of bounds")
            return (buffer + position).pointee
        }
        set {
            precondition(position >= 0 && position < count, "Index out of bounds")
            (buffer + position).pointee = newValue
        }
    }

    // Optional: Explicitly state the index offset
    public func index(after i: Int) -> Int {
        i + 1
    }

    public func index(before i: Int) -> Int {
        i - 1
    }

    // MARK: - Helpers

    private mutating func grow() {
        let newCapacity = capacity * 2
        let newSize = newCapacity * MemoryLayout<Element>.stride

        let rawPtr = allocator.allocate(size: newSize, with: MemoryLayout<Element>.alignment, and: 0)
        let newBuffer = rawPtr.bindMemory(to: Element.self, capacity: newCapacity)

        for i in 0..<count {
            (newBuffer + i).initialize(to: (buffer + i).move())
        }

        allocator.deallocate(at: UnsafeRawPointer(buffer), size: capacity * MemoryLayout<Element>.stride)

        buffer = newBuffer
        capacity = newCapacity
    }

    // MARK: - Deinit

    deinit {
        for i in 0..<count {
            (buffer + i).deinitialize(count: 1)
        }
        allocator.deallocate(at: UnsafeRawPointer(buffer), size: capacity * MemoryLayout<Element>.stride)
    }
}

extension BlitzArray {
    /// The elements of this array represented as a view that works like a sequence
    public var elements: BlitzView<BlitzIterator<Element>> {
        BlitzView(iter: BlitzIterator(buffer: self.buffer, count: self.count))
    }
}

// Utility functions
extension BlitzArray where Element: Comparable {
    /// Sorts this array in place
    /// - Parameters
    ///   - by areInIncreasingOrder: The comparison callback used.
    @inlinable
    public mutating func sort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        let buffer = UnsafeMutableBufferPointer(start: self.buffer, count: self.count)
        _blitzSort(buffer.baseAddress!, count: self.count, by: areInIncreasingOrder)
    }

    /// Returns a native Swift array that is sorted
    /// - Parameters
    ///   - by areInIncreasingOrder: The comparison callback used.
    public func sorted() -> [Element] {
        let buffer = UnsafeBufferPointer(start: self.buffer, count: self.count)
        return Array(buffer).sorted()
    }
}

extension BlitzArray where Element: BlitzPrimitive {
    /// Sorts this array in place
    @inlinable
    public mutating func sort() {
        _blitzSortPrimitive(self.buffer, count: self.count)
    }
}