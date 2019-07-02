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

    func testAppend() {
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

}
