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

    func testCapacity() {
        // 1. Arrange
        let synchronizedArray = SynchronizedArray<Int>()
        let array = [Int]()

        // 3. Assert
        XCTAssertEqual(synchronizedArray.capacity, array.capacity)
    }

    func testAdd() {
        // 1. Arrange
        let synchronizedArray1 = SynchronizedArray<Int>([0, 1, 2])
        let synchronizedArray2 = SynchronizedArray<Int>([3, 4, 5])
        let synchronizedArray3 = SynchronizedArray<Int>([0, 1, 2, 3, 4, 5])

        // 3. Assert
        XCTAssertEqual(synchronizedArray1 + synchronizedArray2, synchronizedArray3)
    }

}
