/// A fast, linear bump allocator used as the default for Blitz containers.
///
/// `BlitzDefaultAllocator` pre-allocates a fixed block of memory and hands out
/// aligned slices of that buffer on request. It does not support deallocation
/// of individual blocks — all allocations are linear, with a "bump" in an
/// internal pointer to track used space.
///
/// This is ideal for high-performance use cases such as:
/// - Short-lived allocations tied to a frame or scope
/// - Custom container backings
/// - Game engines, ECS, and other tooling systems
///
/// ⚠️ All allocations are unchecked except for total capacity. There's no GC,
/// no freeing, and no resizing. You must reset or discard the allocator when done.
///
/// Example:
/// ```swift
/// var allocator = BlitzDefaultAllocator(capacity: 4096)
/// let ptr = allocator.allocate(size: 64, with: 16, and: 0)
/// ```
///
/// - Note: All alignment logic assumes power-of-two alignments. You are
/// responsible for ensuring correct alignment and usage.
public final class BlitzDefaultAllocator: BlitzAllocator {
    let buffer: UnsafeMutableRawPointer
    var currentByte: Int = 0
    let totalCapacity: Int

    public init(capacity: Int) {
        self.buffer = .allocate(byteCount: capacity, alignment: 16)
        self.totalCapacity = capacity
    }

    public func allocate(size bytes: Int) -> UnsafeMutableRawPointer {
        return allocate(size: bytes, with: 1, and: 0)
    }

    public func allocate(size bytes: Int, with alignment: Int, and offset: Int) -> UnsafeMutableRawPointer {
        let raw = Int(bitPattern: buffer) + currentByte
        let misalignment = (raw + offset) & (alignment - 1)
        let adjustment = misalignment == 0 ? 0 : alignment - misalignment
        let alignedOffset = currentByte + adjustment

        precondition(alignedOffset + bytes <= totalCapacity, "Allocator out of memory")

        let ptr = buffer + alignedOffset
        currentByte = alignedOffset + bytes
        return ptr
    }

    public func deallocate(at address: UnsafeRawPointer, size bytes: Int) {
        // No-op
    }
}