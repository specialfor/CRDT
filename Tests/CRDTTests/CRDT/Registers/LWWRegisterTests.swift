//
//  LWWRegisterTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 16.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class LWWRegisterTests: TestCase {

    // MARK: - Init

    func testInit_withDefaultTimestamp_equalToZero() {
        let register = LWWRegister(10)

        XCTAssertEqual(register.value, 10)
        XCTAssertEqual(register.timestamp, 0)
    }

    func testInit_withTimestamp_equalToArgument() {
        let register = LWWRegister(10, timestamp: 10)

        XCTAssertEqual(register.value, 10)
        XCTAssertEqual(register.timestamp, 10)
    }

    // MARK: - Value

    func testValue_get_returnValueFromInit() {
        let register = LWWRegister(5)
        XCTAssertEqual(register.value, 5)
    }

    func testValue_set_setValueAndUpdateTimestamp() {
        var register = LWWRegister(5)

        register.value = 10

        XCTAssertEqual(register.value, 10)
        XCTAssertEqual(register.timestamp, 1)
    }

    // MARK: - Merge

    func testMerge_withNewTimestamp_success() {
        var lhs = LWWRegister(5, timestamp: 0)
        let rhs = LWWRegister(10, timestamp: 1)

        lhs.merge(rhs)

        XCTAssertEqual(lhs.value, 10)
        XCTAssertEqual(lhs.timestamp, 1)
    }

    func testMerge_withSameTimestamp_success() {
        var lhs = LWWRegister(5, timestamp: 1)
        let rhs = LWWRegister(10, timestamp: 1)

        lhs.merge(rhs)

        XCTAssertEqual(lhs.value, 10)
        XCTAssertEqual(lhs.timestamp, 1)
    }

    func testMerge_withOldTimestamp_failure() {
        var lhs = LWWRegister(5, timestamp: 2)
        let rhs = LWWRegister(10, timestamp: 1)

        lhs.merge(rhs)

        XCTAssertEqual(lhs.value, 5)
        XCTAssertEqual(lhs.timestamp, 2)
    }

    // MARK: - HasConflict

    func testHasConflict_withNewTimestamp_false() {
        let lhs = LWWRegister(5, timestamp: 0)
        let rhs = LWWRegister(10, timestamp: 1)

        XCTAssertFalse(lhs.hasConflict(with: rhs))
    }

    func testHasConflict_withSameTimestamp_false() {
        let lhs = LWWRegister(5, timestamp: 1)
        let rhs = LWWRegister(10, timestamp: 1)

        XCTAssertFalse(lhs.hasConflict(with: rhs))
    }

    func testHasConflict_withOldTimestamp_false() {
        let lhs = LWWRegister(5, timestamp: 2)
        let rhs = LWWRegister(10, timestamp: 1)

        XCTAssertFalse(lhs.hasConflict(with: rhs))
    }
}
