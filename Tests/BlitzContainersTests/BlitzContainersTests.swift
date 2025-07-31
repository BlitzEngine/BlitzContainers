import Testing
@testable import BlitzContainers

@Test func arrayCreationTest() async throws {
    // Create default bump allocator with 4KB size
    var allocator = BlitzDefaultAllocator(capacity: 4096)
    var array = BlitzArray<Int, BlitzDefaultAllocator>(capacity: 20, with: allocator)

    array.append(1)
    array.append(20)

    #expect(array[0] == 1)
    #expect(array[1] == 20)
}

@Test func arraySortingTest() async throws {
    // Create default bump allocator with 4KB size
    var allocator = BlitzDefaultAllocator(capacity: 1024 * 1024 * 128)
    var array = BlitzArray<Int32, BlitzDefaultAllocator>(capacity: 20, with: allocator)
    var stdArray: [Int32] = Array<Int32>(repeating: 0, count: 20)

    for x: Int32 in 0..<5000 {
        array.append(x)
        stdArray.append(x)
    }

    let comparator: (Int32, Int32) -> Bool = { a, b in
        (a % 2) > b
    }

    let blitzTime = ContinuousClock().measure {
        array.sort()
    }

    let stdTime = ContinuousClock().measure {
        stdArray.sort()
    }

    print("Blitz: \(blitzTime), std: \(stdTime)")
}