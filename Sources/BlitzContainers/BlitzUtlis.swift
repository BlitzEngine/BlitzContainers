@inlinable
@inline(__always)
func _blitzSort<Element>(
    _ ptr: UnsafeMutablePointer<Element>,
    count: Int,
    by areInIncreasingOrder: (Element, Element) -> Bool
) {
    guard count > 1 else { return }

    func swap(_ i: Int, _ j: Int) {
        Swift.swap(&(ptr + i).pointee, &(ptr + j).pointee)
    }

    func medianOfThree(_ a: Int, _ b: Int, _ c: Int) -> Int {
        let x = (ptr + a).pointee
        let y = (ptr + b).pointee
        let z = (ptr + c).pointee

        if areInIncreasingOrder(x, y) {
            if areInIncreasingOrder(y, z) { return b }
            else if areInIncreasingOrder(x, z) { return c }
            else { return a }
        } else {
            if areInIncreasingOrder(x, z) { return a }
            else if areInIncreasingOrder(y, z) { return c }
            else { return b }
        }
    }

    func insertionSort(low: Int, high: Int) {
        for i in (low + 1)...high {
            var j = i
            while j > low && areInIncreasingOrder((ptr + j).pointee, (ptr + j - 1).pointee) {
                swap(j, j - 1)
                j -= 1
            }
        }
    }

    func partition(low: Int, high: Int) -> Int {
        let mid = (low + high) / 2
        let pivotIndex = medianOfThree(low, mid, high)
        swap(pivotIndex, high)

        let pivot = (ptr + high).pointee
        var i = low

        for j in low..<high {
            if areInIncreasingOrder((ptr + j).pointee, pivot) {
                swap(i, j)
                i += 1
            }
        }
        swap(i, high)
        return i
    }

    func quicksort(low: Int, high: Int) {
        var stack: [(Int, Int)] = [(low, high)]

        while let (lo, hi) = stack.popLast() {
            if hi - lo <= 12 {
                insertionSort(low: lo, high: hi)
                continue
            }

            let p = partition(low: lo, high: hi)
            if p - 1 > lo { stack.append((lo, p - 1)) }
            if p + 1 < hi { stack.append((p + 1, hi)) }
        }
    }

    quicksort(low: 0, high: count - 1)
}

@inlinable
@inline(__always)
func _blitzSortPrimitive<T: BlitzPrimitive>(
    _ ptr: UnsafeMutablePointer<T>,
    count: Int
) {
    guard count > 1 else { return }

    func swap(_ i: Int, _ j: Int) {
        let tmp = ptr[i]
        ptr[i] = ptr[j]
        ptr[j] = tmp
    }

    func insertionSort(_ low: Int, _ high: Int) {
        for i in (low + 1)...high {
            var j = i
            while j > low && ptr[j] < ptr[j - 1] {
                swap(j, j - 1)
                j -= 1
            }
        }
    }

    func medianOfThree(_ a: Int, _ b: Int, _ c: Int) -> Int {
        let x = ptr[a], y = ptr[b], z = ptr[c]
        if x < y {
            if y < z { return b }
            else if x < z { return c }
            else { return a }
        } else {
            if x < z { return a }
            else if y < z { return c }
            else { return b }
        }
    }

    func partition(_ low: Int, _ high: Int) -> Int {
        let mid = (low + high) / 2
        let pivotIndex = medianOfThree(low, mid, high)
        swap(pivotIndex, high)
        let pivot = ptr[high]
        var i = low
        for j in low..<high {
            if ptr[j] < pivot {
                swap(i, j)
                i += 1
            }
        }
        swap(i, high)
        return i
    }

    func quicksort(_ low: Int, _ high: Int) {
        var stack: [(Int, Int)] = [(low, high)]
        while let (lo, hi) = stack.popLast() {
            if hi - lo <= 12 {
                insertionSort(lo, hi)
                continue
            }
            let p = partition(lo, hi)
            if p - 1 > lo { stack.append((lo, p - 1)) }
            if p + 1 < hi { stack.append((p + 1, hi)) }
        }
    }

    quicksort(0, count - 1)
}