/// A protocol representing a low-level memory allocator used by BlitzContainers.
///
/// `BlitzAllocator` abstracts over raw memory allocation, providing precise control
/// over how memory is allocated and deallocated. Unlike high-level Swift allocations,
/// Blitz allocators operate directly on `UnsafeRawPointer` and are intended for
/// performance-critical, deterministic memory management.
///
/// - Note: All implementations **must** respect alignment and offset requirements
///         and ensure that allocations are non-overlapping and correctly aligned.
///
/// Allocators conforming to this protocol are responsible for:
/// - Providing raw memory blocks of a given size
/// - Handling alignment and offset constraints
/// - Explicit deallocation of memory (if applicable)
///
/// This protocol is restricted to reference types (`AnyObject`) to ensure allocator
/// instances can be shared across multiple containers without copying.
public protocol BlitzAllocator: AnyObject {

    /// Allocates a raw memory block of at least `bytes` size.
    ///
    /// - Parameter bytes: The size, in bytes, of the memory to allocate.
    /// - Returns: A pointer to the beginning of the allocated memory region.
    func allocate(size bytes: Int) -> UnsafeMutableRawPointer

    /// Allocates a raw memory block of at least `bytes` size, with custom alignment and offset.
    ///
    /// - Parameters:
    ///   - bytes: The size, in bytes, of the memory to allocate.
    ///   - alignment: Desired byte alignment. Must be a power of two.
    ///   - offset: The offset, in bytes, to ensure alignment from.
    /// - Returns: A pointer to the beginning of the aligned memory region.
    func allocate(size bytes: Int, with alignment: Int, and offset: Int) -> UnsafeMutableRawPointer

    /// Deallocates a previously allocated memory block.
    ///
    /// - Parameters:
    ///   - address: The starting address of the memory region to deallocate.
    ///   - bytes: The size of the region to deallocate.
    func deallocate(at address: UnsafeRawPointer, size bytes: Int)
}