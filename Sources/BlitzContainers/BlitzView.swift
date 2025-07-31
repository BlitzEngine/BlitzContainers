/// A lightweight, single-pass view over an iterator.
///
/// `BlitzView` wraps an `IteratorProtocol` and exposes it as a `Sequence`,
/// allowing it to be used in any codebase that uses Sequences.
///
/// - Note: `BlitzView` is intentionally minimal. It is not a collection, and
///         does **not** support multiple passes or random access.
///
/// - Parameters:
///   - Iter: The iterator type conforming to `IteratorProtocol`.
public struct BlitzView<Iter: IteratorProtocol>: Sequence {
    private var iter: Iter

    public init(iter: Iter) {
        self.iter = iter
    }

    public func makeIterator() -> Iter {
        return iter
    }
}