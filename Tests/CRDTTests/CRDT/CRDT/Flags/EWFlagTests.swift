//
//  EWFlagTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 20.04.2020.
//

import XCTest

@testable import CRDT

final class EWFlagTests: TestCase {

    // MARK: - Init

    func testInit_default_equalsFalse() {
        let flag = EWFlag()
        XCTAssertFalse(flag.value)
    }

    func testInit_expressibleByBooleanLiterals_equalsLiteral() {
        let flag: EWFlag = true
        XCTAssertTrue(flag.value)
    }

    // MARK: - Value

    func testValue() {
        var flag: EWFlag = true
        XCTAssertTrue(flag.value)

        flag.value = false
        XCTAssertFalse(flag.value)

        flag.value = true
        XCTAssertTrue(flag.value)

        flag.value = false
        XCTAssertFalse(flag.value)

        flag.value = false
        XCTAssertFalse(flag.value)

        flag.value = true
        XCTAssertTrue(flag.value)

        flag.value = true
        XCTAssertTrue(flag.value)

        flag.value = false
        XCTAssertFalse(flag.value)
    }

    // MARK: - Merge

    func testMerge() {
        var flag1: EWFlag = true
        var flag2 = flag1

        flag1.value = true
        flag2.value = false

        let result = flag1.merging(flag2)

        XCTAssertTrue(result.value)
    }

    // MARK: - HasConflict

    func testHasConflict() {
        var flag1: EWFlag = true
        var flag2 = flag1

        flag1.value = true
        flag2.value = false

        XCTAssertFalse(flag1.hasConflict(with: false))
        XCTAssertFalse(flag1.hasConflict(with: true))
        XCTAssertFalse(flag1.hasConflict(with: flag1))
        XCTAssertFalse(flag1.hasConflict(with: flag2))
        XCTAssertFalse(flag2.hasConflict(with: flag2))
        XCTAssertFalse(flag2.hasConflict(with: false))
        XCTAssertFalse(flag2.hasConflict(with: true))
    }
}
