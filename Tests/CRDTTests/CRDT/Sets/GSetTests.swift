//
//  GSetTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 18.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class GSetTests: TestCase {

    // MARK: - Init

    func testDefaultInit_setValue_toEmpty() {
        let set = GSet<Int>()

        XCTAssertEqual(set.value, [])
    }

    // MARK: - Insert

    func testInsert_element_intoValue() {
        var set: GSet<Int> = [1]

        set.insert(1)
        set.insert(2)

        XCTAssertEqual(set.value, [1, 2])
    }

    // MARK: - Remove

    func testRemove_assertAndReturnNil() {
        var set: GSet<Int> = [1]

        let result = set.remove(1)

        XCTAssertNil(result)
        XCTAssertEqual(set.value, [1])
        assertFullfilledExpectation(assertionFailureExpectation)
    }

    // MARK: - Merge

    func testMerge() {
        let set: GSet<Int> = [1, 2]

        XCTAssertEqual(set.merging(set).value, set.value)
        XCTAssertEqual(set.merging([]).value, set.value)
        XCTAssertEqual(set.merging([1, 3]).value, [1, 2, 3])
        XCTAssertEqual(set.merging([3, 4]).value, [1, 2, 3, 4])
    }

    // MARK: - HasConflict

    func testHasConflict() {
        let set: GSet<Int> = [1, 2]

        XCTAssertFalse(set.hasConflict(with: set))
        XCTAssertFalse(set.hasConflict(with: []))
        XCTAssertFalse(set.hasConflict(with: [1, 3]))
        XCTAssertFalse(set.hasConflict(with: [3, 4]))
    }

    // MARK: - Comparable

    func testCompare() {
        let empty: GSet<Int> = []
        let smallest: GSet<Int> = [1]
        let normal: GSet<Int> = [1, 2]
        let normalNotDisjoint: GSet<Int> = [1, 3]
        let normalDisjoint: GSet<Int> = [4, 5]
        let biggest: GSet<Int> = [1, 2, 3]

        // <
        XCTAssertLessThan(empty, smallest)
        XCTAssertLessThan(smallest, normal)
        XCTAssertLessThan(normal, biggest)
        XCTAssertFalse(normal < normal)
        XCTAssertFalse(normal < normalNotDisjoint)
        XCTAssertFalse(normal < normalDisjoint)

        // <=
        XCTAssertLessThanOrEqual(empty, smallest)
        XCTAssertLessThanOrEqual(smallest, normal)
        XCTAssertLessThanOrEqual(normal, biggest)
        XCTAssertLessThanOrEqual(normal, normal)
        XCTAssertFalse(normal <= normalNotDisjoint)
        XCTAssertFalse(normal <= normalDisjoint)

        // >
        XCTAssertGreaterThan(smallest, empty)
        XCTAssertGreaterThan(normal, smallest)
        XCTAssertGreaterThan(biggest, normal)
        XCTAssertFalse(normal > normal)
        XCTAssertFalse(normalNotDisjoint > normal)
        XCTAssertFalse(normalDisjoint > normal)

        // >=
        XCTAssertGreaterThanOrEqual(smallest, empty)
        XCTAssertGreaterThanOrEqual(normal, smallest)
        XCTAssertGreaterThanOrEqual(biggest, normal)
        XCTAssertGreaterThanOrEqual(normal, normal)
        XCTAssertFalse(normalNotDisjoint >= normal)
        XCTAssertFalse(normalDisjoint >= normal)
    }

    // MARK: - Equatable

    func testEqual() {
        let empty: GSet<Int> = []
        let set: GSet<Int> = [1, 2]
        let disjointSet: GSet<Int> = [3, 4]
        let notDisjointSet: GSet<Int> = [1, 4]

        XCTAssertEqual(set, [1, 2])
        XCTAssertEqual(empty, [])

        XCTAssertNotEqual(set, disjointSet)
        XCTAssertNotEqual(set, notDisjointSet)
        XCTAssertNotEqual(disjointSet, notDisjointSet)
    }
}
