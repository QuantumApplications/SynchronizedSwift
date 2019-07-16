//
//  ArrayTests.swift
//  SynchronizedSwiftTests
//
//  Created by Christian Oberdörfer on 02.07.19.
//  Copyright © 2019 Christian Oberdörfer. All rights reserved.
//

import XCTest
@testable import SynchronizedSwift

enum TestError: Error {
    case expectedError
}

class ArrayTests: XCTestCase {

    var array1 = Array<Int>()
    var array2 = Array<Int>()
    var addedArray = Array<Int>()
    let array1Capacity = 5
    let array1Sum = 10
    let array1Swapped = Array<Int>([1, 0, 3, 2, 4])
    let array1ReplacedSubrage = Array<Int>([0, 1, 1, 1, 1, 1, 4])
    var arrayBytes = Array<Int32>([0, 0])
    let byteValues: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00]
    let array1ReplacedBytes = Array<Int32>([1, 2])
    let array1Doubled = Array<Int>([0, 2, 4, 6, 8])
    let array1Last = 4
    let array1Partitioned = Array<Int>([4, 3, 2, 1, 0])
    let array1String = Array<String>(["0", "1", "two", "three", "4"])
    let array1Compact = Array<Int>([0, 1, 4])
    let array1SwappedAt1 = Array<Int>([1, 0, 2, 3, 4])
    let array1Range = 0..<5
    let array1Repeated = Array<Int>([0, 0, 0, 0, 0])
    let array1Appended = Array<Int>([0, 1, 2, 3, 4, 5])
    let array1Inserted = Array<Int>([0, 5, 1, 2, 3, 4])
    let array1InsertedContentsOf = Array<Int>([0, 1, 5, 6, 7, 8, 9, 2, 3, 4])
    let array1Removed = Array<Int>([0, 1, 2, 4])
    let array1RemovedSubrange = Array<Int>([0, 4])
    let array1RemovedFirstK = Array<Int>([2, 3, 4])
    let array1RemovedFirst = Array<Int>([1, 2, 3, 4])
    let empyArray = Array<Int>()
    let newCapacity = 10
    let array1RemovedLast = Array<Int>([0, 1, 2, 3])
    let array1RemovedLastK = Array<Int>([0, 1, 2])

    override func setUp() {
        self.array1 = Array<Int>([0, 1, 2, 3, 4])
        self.array2 = Array<Int>([5, 6, 7, 8, 9])
        self.addedArray = Array<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }

    // MARK: - Array

    func testCapacity() {
        // 3. Assert
        XCTAssertEqual(self.array1.capacity, self.array1Capacity)
    }

    func testAdd() {
        // 3. Assert
        XCTAssertEqual(self.array1 + self.array2, self.addedArray)
    }

    func testAppendOperator() {
        // 2. Action
        self.array1 += self.array2

        // 3. Assert
        XCTAssertEqual(self.array1, self.addedArray)
    }

    func testWithUnsafeBufferPointer() {
        // 2. Action
        let sum = self.array1.withUnsafeBufferPointer { buffer -> Int in
            var result = 0
            for i in stride(from: buffer.startIndex, to: buffer.endIndex, by: 1) {
                result += buffer[i]
            }
            return result
        }

        // 3. Assert
        XCTAssertEqual(sum, self.array1Sum)
    }

    func unsafeBufferPointerThrows() throws {
        // 2. Action
        _ = try self.array1.withUnsafeBufferPointer { buffer -> Int in
            throw TestError.expectedError
        }
    }

    func testWithUnsafeBufferPointerException() {
        // 3. Assert
        XCTAssertThrowsError(try unsafeBufferPointerThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testWithUnsafeMutableBufferPointer() {
        // 2. Action
        self.array1.withUnsafeMutableBufferPointer { buffer in
            for i in stride(from: buffer.startIndex, to: buffer.endIndex - 1, by: 2) {
                buffer.swapAt(i, i + 1)
            }
        }

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1Swapped)
    }

    func unsafeMutableBufferPointerThrows() throws {
        // 2. Action
        _ = try self.array1.withUnsafeMutableBufferPointer { buffer -> Int in
            throw TestError.expectedError
        }
    }

    func testWithUnsafeMutableBufferPointerException() {
        // 3. Assert
        XCTAssertThrowsError(try unsafeMutableBufferPointerThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testReplaceSubrange() {
        // 2. Action
        self.array1.replaceSubrange(1..<4, with: repeatElement(1, count: 5))

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1ReplacedSubrage)
    }

    func testWithUnsafeMutableBytes() {
        // 2. Action
        self.arrayBytes.withUnsafeMutableBytes { destBytes in
            self.byteValues.withUnsafeBytes { srcBytes in
                destBytes.copyBytes(from: srcBytes)
            }
        }

        // 3. Assert
        XCTAssertEqual(self.arrayBytes, self.array1ReplacedBytes)
    }

    func unsafeMutableBytesThrows() throws {
        // 2. Action
        _ = try self.arrayBytes.withUnsafeMutableBytes { bytes in
            throw TestError.expectedError
        }
    }

    func testWithUnsafeMutableBytesException() {
        // 3. Assert
        XCTAssertThrowsError(try unsafeMutableBytesThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testWithUnsafeBytes() {
        // 1. Arrange
        var byteBuffer: [UInt8] = []

        // 2. Action
        self.array1ReplacedBytes.withUnsafeBytes {
            byteBuffer.append(contentsOf: $0)
        }

        // 3. Assert
        XCTAssertEqual(byteBuffer, self.byteValues)
    }

    func unsafeBytesThrows() throws {
        // 2. Action
        _ = try self.array1ReplacedBytes.withUnsafeBytes { bytes in
            throw TestError.expectedError
        }
    }

    func testWithUnsafeBytesException() {
        // 3. Assert
        XCTAssertThrowsError(try unsafeBytesThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testMap() {
        // 3. Assert
        XCTAssertEqual(self.array1.map { $0 * 2 }, self.array1Doubled)
    }

    func mapThrows() throws {
        // 2. Action
        _ = try self.array1.map { array in
            throw TestError.expectedError
        }
    }

    func testMapException() {
        // 3. Assert
        XCTAssertThrowsError(try mapThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testLast() {
        // 3. Assert
        XCTAssertEqual(self.array1.last, self.array1Last)
    }

    func testFirstIndex() {
        // 3. Assert
        XCTAssertEqual(self.array1.firstIndex { $0 > 2 }, 3)
    }

    func firstIndexThrows() throws {
        // 2. Action
        _ = try self.array1.firstIndex { array in
            throw TestError.expectedError
        }
    }

    func testFirstIndexException() {
        // 3. Assert
        XCTAssertThrowsError(try firstIndexThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testLastWhere() {
        // 3. Assert
        XCTAssertEqual(self.array1.last { $0 < 2 }, 1)
    }

    func lastWhereThrows() throws {
        // 2. Action
        _ = try self.array1.last { array in
            throw TestError.expectedError
        }
    }

    func testLastWhereException() {
        // 3. Assert
        XCTAssertThrowsError(try lastWhereThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testLastIndexWhere() {
        // 3. Assert
        XCTAssertEqual(self.array1.lastIndex { $0 < 2 }, 1)
    }

    func lastIndexWhereThrows() throws {
        // 2. Action
        _ = try self.array1.lastIndex { array in
            throw TestError.expectedError
        }
    }

    func testLastIndexWhereException() {
        // 3. Assert
        XCTAssertThrowsError(try lastIndexWhereThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testPartition() {
        // 2. Action
        let firstIndex = self.array1.partition { $0 < 2 }

        // 3. Assert
        XCTAssertEqual(firstIndex, 3)
        XCTAssertEqual(self.array1, self.array1Partitioned)
    }

    func partitionThrows() throws {
        // 2. Action
        _ = try self.array1.partition { array in
            throw TestError.expectedError
        }
    }

    func testPartitionThrowsException() {
        // 3. Assert
        XCTAssertThrowsError(try partitionThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testShuffledUsingGenerator() {
        // 1. Arrange
        var randomNumberGenerator = SystemRandomNumberGenerator()

        // 3. Assert
        XCTAssertNotEqual(self.array1.shuffled(using: &randomNumberGenerator), self.array1)
    }

    func testShuffled() {
        // 3. Assert
        XCTAssertNotEqual(self.array1.shuffled(), self.array1)
    }

    func testShuffleUsingGenerator() {
        // 1. Arrange
        var randomNumberGenerator = SystemRandomNumberGenerator()

        // 2. Action
        self.array1.shuffle(using: &randomNumberGenerator)

        // 3. Assert
        XCTAssertNotEqual(self.array1, self.array2)
    }

    func testShuffle() {
        // 2. Action
        self.array1.shuffle()

        // 3. Assert
        XCTAssertNotEqual(self.array1, self.array2)
    }

    func testFlatMap() {
        // 3. Assert
        XCTAssertEqual(self.array1String.flatMap { Int($0) }, self.array1Compact)
    }

    func flatMapThrows() throws {
        // 2. Action
        _ = try self.array1.flatMap { array in
            throw TestError.expectedError
        }
    }

    func testFlatMapThrowsException() {
        // 3. Assert
        XCTAssertThrowsError(try flatMapThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testWithContiguousMutableStorageIfAvailable() {
        // 2. Action
        let sum = self.array1.withContiguousMutableStorageIfAvailable { buffer -> Int in
            var result = 0
            for i in stride(from: buffer.startIndex, to: buffer.endIndex, by: 1) {
                result += buffer[i]
            }
            return result
        }

        // 3. Assert
        XCTAssertEqual(sum, self.array1Sum)
    }

    func withContiguousMutableStorageIfAvailableThrows() throws {
        // 2. Action
        _ = try self.array1.withContiguousMutableStorageIfAvailable { buffer -> Int in
            throw TestError.expectedError
        }
    }

    func testWithContiguousMutableStorageIfAvailableException() {
        // 3. Assert
        XCTAssertThrowsError(try withContiguousMutableStorageIfAvailableThrows()) { error in
            XCTAssertEqual(error as! TestError, TestError.expectedError)
        }
    }

    func testSwapAt() {
        // 2.Action
        self.array1.swapAt(0, 1)

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1SwappedAt1)
    }

    func testIndices() {
        // 3. Assert
        XCTAssertEqual(self.array1.indices, array1Range)
    }

    func testInitRepeating() {
        // 3. Assert
        XCTAssertEqual(Array(repeating: 0, count: 5), self.array1Repeated)
    }

    func testInitSequence() {
        // 3. Assert
        XCTAssertEqual(Array(Set(self.array2)).sorted(), self.array2)
    }

    func testAppend() {
        // 2. Action
        self.array1.append(5)

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1Appended)
    }

    func testAppendSequence() {
        // 2. Action
        self.array1.append(contentsOf: self.array2)

        // 3. Assert
        XCTAssertEqual(self.array1, self.addedArray)
    }

    func testInsert() {
        // 2. Action
        self.array1.insert(5, at: 1)

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1Inserted)
    }

    func testInsertContentsOf() {
        // 2. Action
        self.array1.insert(contentsOf: 5..<10, at: 2)

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1InsertedContentsOf)
    }

    func testRemove() {
        // 2. Action
        let removed = self.array1.remove(at: 3)

        // 3. Assert
        XCTAssertEqual(removed, 3)
        XCTAssertEqual(self.array1, self.array1Removed)
    }

    func testRemoveSubrange() {
        // 2. Action
        self.array1.removeSubrange(1..<4)

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1RemovedSubrange)
    }

    func testRemoveFirstK() {
        // 2. Action
        self.array1.removeFirst(2)

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1RemovedFirstK)
    }

    func testRemoveFirst() {
        // 2. Action
        let removed = self.array1.removeFirst()

        // 3. Assert
        XCTAssertEqual(removed, 0)
        XCTAssertEqual(self.array1, self.array1RemovedFirst)
    }

    func testRemoveAll() {
        // 2. Action
        self.array1.removeAll(keepingCapacity: true)

        // 3. Assert
        XCTAssertEqual(self.array1, self.empyArray)
        XCTAssertEqual(self.array1.capacity, self.array1Capacity)
    }

    func testReserveCapacity() {
        // 2. Action
        self.array1.reserveCapacity(self.newCapacity)

        // 3. Assert
        XCTAssertEqual(self.array1.capacity, self.newCapacity)
    }

    func testPopLast() {
        // 2. Action
        let last = self.array1.popLast()

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1RemovedLast)
        XCTAssertEqual(last, self.array1Last)
    }

    func testRemoveLast() {
        // 2. Action
        let last = self.array1.removeLast()

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1RemovedLast)
        XCTAssertEqual(last, self.array1Last)
    }

    func testRemoveLastK() {
        // 2. Action
        self.array1.removeLast(2)

        // 3. Assert
        XCTAssertEqual(self.array1, self.array1RemovedLastK)
    }

}
