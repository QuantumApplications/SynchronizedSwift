//
//  SynchronizedArrayTests.swift
//  SynchronizedSwiftTests
//
//  Created by Christian Oberdörfer on 24.06.19.
//  Copyright © 2019 Christian Oberdörfer. All rights reserved.
//

import XCTest
@testable import SynchronizedSwift

class SynchronizedArrayTests: XCTestCase {

    var array1 = SynchronizedArray<Int>()
    var array2 = SynchronizedArray<Int>()
    var addedArray = SynchronizedArray<Int>()
    let array1Capacity = 5
    let array1Sum = 10
    let array1Swapped = SynchronizedArray<Int>([1, 0, 3, 2, 4])
    let nonSynchronizedArray2 = Array<Int>([5, 6, 7, 8, 9])
    let array1ReplacedSubrage = SynchronizedArray<Int>([0, 1, 1, 1, 1, 1, 4])
    var arrayBytes = SynchronizedArray<Int32>([0, 0])
    let byteValues: [UInt8] = [0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00]
    let array1ReplacedBytes = SynchronizedArray<Int32>([1, 2])
    let array1Doubled = SynchronizedArray<Int>([0, 2, 4, 6, 8])
    let array1Last = 4
    let array1Partitioned = SynchronizedArray<Int>([4, 3, 2, 1, 0])
    let array1String = SynchronizedArray<String>(["0", "1", "two", "three", "4"])
    let array1Compact = SynchronizedArray<Int>([0, 1, 4])
    let array1SwappedAt1 = SynchronizedArray<Int>([1, 0, 2, 3, 4])
    let array1Range = 0..<5
    let array1Repeated = SynchronizedArray<Int>([0, 0, 0, 0, 0])
    let array1Appended = SynchronizedArray<Int>([0, 1, 2, 3, 4, 5])
    let array1Inserted = SynchronizedArray<Int>([0, 5, 1, 2, 3, 4])
    let array1InsertedContentsOf = SynchronizedArray<Int>([0, 1, 5, 6, 7, 8, 9, 2, 3, 4])
    let array1Removed = SynchronizedArray<Int>([0, 1, 2, 4])

    override func setUp() {
        self.array1 = SynchronizedArray<Int>([0, 1, 2, 3, 4])
        self.array2 = SynchronizedArray<Int>([5, 6, 7, 8, 9])
        self.addedArray = SynchronizedArray<Int>([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
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

    func testAddNonSynchronized() {
        // 3. Assert
        XCTAssertEqual(self.array1 + self.nonSynchronizedArray2, self.addedArray)
    }

    func testAppendOperator() {
        // 2. Action
        self.array1 += self.array2

        // 3. Assert
        XCTAssertEqual(self.array1, self.addedArray)
    }

    func testAppendOperatorNonSynchronized() {
        // 2. Action
        self.array1 += self.nonSynchronizedArray2

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
        self.array1.replaceSubrange(1..<4, with: repeatElement(1, count: 5)) {
            // 3. Assert
            XCTAssertEqual(self.array1, self.array1ReplacedSubrage)
        }
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
        self.array1.shuffle() {
            // 3. Assert
            XCTAssertNotEqual(self.array1, self.array2)
        }
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
        // 2. Action
        self.array1.swapAt(0, 1) {
            // 3. Assert
            XCTAssertEqual(self.array1, self.array1SwappedAt1)
        }
    }

    func testIndices() {
        // 3. Assert
        XCTAssertEqual(self.array1.indices, array1Range)
    }

    func testInitRepeating() {
        // 3. Assert
        XCTAssertEqual(SynchronizedArray(repeating: 0, count: 5), self.array1Repeated)
    }

    func testInitSequence() {
        // 3. Assert
        XCTAssertEqual(SynchronizedArray(Set(self.nonSynchronizedArray2)).sorted(), self.array2)
    }

    func testAppend() {
        // 2. Action
        self.array1.append(5) {
            // 3. Assert
            XCTAssertEqual(self.array1, self.array1Appended)
        }
    }

    func testAppendSynchronized() {
        // 2. Action
        self.array1.append(contentsOf: self.array2) {
            // 3. Assert
            XCTAssertEqual(self.array1, self.addedArray)
        }
    }

    func testAppendSequenceNonSynchronized() {
        // 2. Action
        self.array1.append(contentsOf: self.nonSynchronizedArray2) {
            // 3. Assert
            XCTAssertEqual(self.array1, self.addedArray)
        }
    }

    func testInsert() {
        // 2. Action
        self.array1.insert(5, at: 1) {
            // 3. Assert
            XCTAssertEqual(self.array1, self.array1Inserted)
        }
    }

    func testInsertContentsOf() {
        // 2. Action
        self.array1.insert(contentsOf: 5..<10, at: 2) {
            // 3. Assert
            XCTAssertEqual(self.array1, self.array1InsertedContentsOf)
        }
    }

    func testRemove() {
        // 2. Action
        let removed = self.array1.remove(at: 3)

        // 3. Assert
        XCTAssertEqual(removed, 3)
        XCTAssertEqual(self.array1, self.array1Removed)
    }

}
