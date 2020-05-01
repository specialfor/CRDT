//
//  ArrayExtensionTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class ArrayExtensionTest: XCTestCase {

    func testFillBy_toCountGreateThenCurrent_fillUp() {
        var array: [Int] = []

        array.fillUp(by: 2, to: 3)

        XCTAssertEqual(array, [2, 2, 2])
    }

    func testFillBy_toCountLessThenCurrent_doNothing() {
        var array = [1, 2, 3]

        array.fillUp(by: 4, to: 2)

        XCTAssertEqual(array, [1, 2, 3])
    }

    func testFillBy_toCountEqualToCurrent_doNothing() {
        var array = [1, 2, 3]

        array.fillUp(by: 4, to: 3)

        XCTAssertEqual(array, [1, 2, 3])
    }
}
