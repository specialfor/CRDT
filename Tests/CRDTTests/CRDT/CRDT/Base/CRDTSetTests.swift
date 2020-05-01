//
//  CRDTSetTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 18.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class CRDTSetTests: XCTestCase {

    // MARK: - Init

    func testInit_setValue_toEmpty() {
        let set: some CRDTSet = GSet<String>()
        XCTAssertEqual(set.value, [])
    }

    func testInit_set_arrayLiteral() {
        let set: some CRDTSet = [1, 2, 3, 4] as GSet<Int>
        XCTAssertEqual(set.value as! Set<Int>, Set([1, 2, 3, 4]))
    }

    // MARK: - isEmpty

    func testIsEmpty_onEmpty_true() {
        let set: some CRDTSet = [] as GSet<Int>
        XCTAssertTrue(set.isEmpty)
    }

    func testIsEmpty_onNonEmpty_false() {
        let set: some CRDTSet = [1] as GSet<Int>
        XCTAssertFalse(set.isEmpty)
    }
}
