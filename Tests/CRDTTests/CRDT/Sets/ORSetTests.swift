//
//  ORSetTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

import XCTest

@testable import CRDT

final class ORSetTests: TestCase {

    // MARK: - Init

    func testInit_default_valueEqualsEmpty() {
        let set = ORSet<Int>()

        XCTAssertEqual(set.value, [])
    }

    func testInit_expressibleByArrayLiteral_valueEqualArrayLiteral() {
        let set: ORSet<Int> = [1, 2]

        XCTAssertEqual(set.value, [1, 2])
        XCTAssertEqual(set.payload.value, [
            .init(value: 1, timestamp: 1),
            .init(value: 2, timestamp: 2),
        ])
    }

    // MARK: - Merge

    func testMerge_withEmpty_equalsInitial() {
        let set: ORSet<Int> = [1, 2]

        let result = set.merging([])

        XCTAssertEqual(result.value, set.value)
    }

    func testMerge_concurrentAddRemove_containsAdd() {
        var set: ORSet<Int> = [1, 2]
        var set2 = set

        set.insert(2)
        set2.remove(1)
        set2.remove(2)

        let result = set.merging(set2)

        XCTAssertEqual(result.value, [2])
        XCTAssertEqual(result.payload.value, [
            .init(value: 2, timestamp: 3)
        ])
    }

    // MARK: - HasConflict

    func testHasConflict() {
        var set1: ORSet<Int> = [1, 2]
        set1.remove(2)
        set1.insert(1)
        set1.insert(1)
        set1.insert(2)
        set1.insert(3)

        XCTAssertFalse(set1.hasConflict(with: []))
        XCTAssertFalse(set1.hasConflict(with: [1]))
        XCTAssertFalse(set1.hasConflict(with: [1, 2]))
        XCTAssertFalse(set1.hasConflict(with: [1, 3]))
        XCTAssertFalse(set1.hasConflict(with: [1, 2, 3]))
    }

    // MARK: - Comparable

    func testCompare() {
        let set0: ORSet<Int> = .init()
        let set1: ORSet<Int> = [1]
        let set2: ORSet<Int> = [1, 2]

        var set3: ORSet<Int> = [1, 2, 3]
        set3.remove(3)

        var set4 = set2
        set4.insert(2)

        var set5: ORSet<Int> = [1, 2, 3]
        set5.remove(2)

        // <
        XCTAssertLessThan(set0, set1)
        XCTAssertLessThan(set1, set2)
        XCTAssertFalse(set2 < set2)
        XCTAssertLessThan(set2, set3)
        XCTAssertLessThan(set2, set4)
        XCTAssertFalse(set3 < set4)
        XCTAssertLessThan(set4, set5)
        XCTAssertFalse(set3 < set5)

        // <=
        XCTAssertLessThanOrEqual(set0, set1)
        XCTAssertLessThanOrEqual(set1, set2)
        XCTAssertLessThanOrEqual(set2, set2)
        XCTAssertLessThanOrEqual(set2, set3)
        XCTAssertLessThanOrEqual(set2, set4)
        XCTAssertFalse(set3 <= set4)
        XCTAssertLessThanOrEqual(set4, set5)
        XCTAssertFalse(set3 <= set5)

        // >
        XCTAssertGreaterThan(set1, set0)
        XCTAssertGreaterThan(set2, set1)
        XCTAssertFalse(set2 > set2)
        XCTAssertGreaterThan(set3, set2)
        XCTAssertGreaterThan(set4, set2)
        XCTAssertFalse(set4 > set3)
        XCTAssertGreaterThan(set5, set4)
        XCTAssertFalse(set5 > set3)

        // >=
        XCTAssertGreaterThanOrEqual(set1, set0)
        XCTAssertGreaterThanOrEqual(set2, set1)
        XCTAssertGreaterThanOrEqual(set2, set2)
        XCTAssertGreaterThanOrEqual(set3, set2)
        XCTAssertGreaterThanOrEqual(set4, set2)
        XCTAssertFalse(set4 >= set3)
        XCTAssertGreaterThanOrEqual(set5, set4)
        XCTAssertFalse(set5 >= set3)
    }

    // MARK: - Equatable

    func testEqual() {
        let set0: ORSet<Int> = .init()
        let set1: ORSet<Int> = [1]
        let set2: ORSet<Int> = [1, 2]

        var set3: ORSet<Int> = [1, 2, 3]
        set3.remove(3)

        var set4 = set2
        set4.insert(2)

        var set5: ORSet<Int> = [1, 2, 3]
        set5.remove(3)

        XCTAssertEqual(set0, [])
        XCTAssertEqual(set1, set1)
        XCTAssertEqual(set2, set2)
        XCTAssertEqual(set3, set3)

        XCTAssertNotEqual(set1, [1])
        XCTAssertNotEqual(set2, [1, 2])
        XCTAssertNotEqual(set3, set5)
        XCTAssertNotEqual(set2, set3)
        XCTAssertNotEqual(set2, set4)
        XCTAssertNotEqual(set3, set4)
        XCTAssertNotEqual(set4, set5)
    }

    // MARK: - Insert

    func testInsert() {
        var set1: ORSet<Int> = [1]

        let result1 = set1.insert(1)
        let result2 = set1.insert(2)

        XCTAssertEqual(set1.value, [1, 2])
        XCTAssertEqual(set1.payload.value, [
            .init(value: 1, timestamp: 1),
            .init(value: 1, timestamp: 2),
            .init(value: 2, timestamp: 3),
        ])
        XCTAssertFalse(result1.inserted)
        XCTAssertEqual(result1.memberAfterInsert, 1)
        XCTAssertTrue(result2.inserted)
        XCTAssertEqual(result2.memberAfterInsert, 2)
    }

    // MARK: - Remove

    func testRemove() {
        var set: ORSet<Int> = [1, 2]

        set.insert(2)
        let result1 = set.remove(3)
        let result2 = set.remove(2)

        XCTAssertEqual(set.value, [1])
        XCTAssertEqual(set.payload.value, [.init(value: 1, timestamp: 1)])
        XCTAssertNil(result1)
        XCTAssertEqual(result2, 2)
    }

    // MARK: - Update

    func testUpdate() {
        var set: ORSet<Int> = [1]

        let result1 = set.update(with: 1)
        let result2 = set.update(with: 2)

        XCTAssertEqual(set.value, [1, 2])
        XCTAssertEqual(set.payload.value, [
            .init(value: 1, timestamp: 1),
            .init(value: 1, timestamp: 2),
            .init(value: 2, timestamp: 3),
        ])
        XCTAssertEqual(result1, 1)
        XCTAssertNil(result2)
    }
}
