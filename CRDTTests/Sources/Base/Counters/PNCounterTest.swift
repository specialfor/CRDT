//
//  PNCounterTest.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class PNCounterTest: XCTestCase {

    // MARK: - Value

    func testValue_calculates_correctly() {
        let counters: [PNCounter] = [
            .init([1, 2], [0, 0]),
            .init([0, 0], [1, 2]),
            .init([1, 1], [1, 1])
        ]

        let expectedReults = [
            3,
            -3,
            0
        ]

        let actualResults = counters.map { $0.value }

        XCTAssertEqual(actualResults, expectedReults)
    }

    // MARK: - Update

    func testIncrementDecrement_incementDecrement_correctElement() {
        var counter = PNCounter([0, 0], [0, 0])
        counter.replicaNumber = 1

        counter.increment()
        counter.decrement()

        XCTAssertEqual(counter, PNCounter([0, 1], [0, 1]))
    }

    func testIncrementDecrement_incrementDecrement_byOne() {
        var counter = PNCounter([0, 0], [0, 0])
        counter.replicaNumber = 1

        counter.increment()
        counter.increment()
        counter.increment()

        counter.decrement()
        counter.decrement()

        XCTAssertEqual(counter, PNCounter([0, 3], [0, 2]))
    }

    // MARK: - Merge

    func testMerge_merge_byMaxComponent() {
        var lhs = PNCounter([0, 1], [1, 0])
        let rhs = PNCounter([1, 0], [0, 1])

        lhs.merge(rhs)

        XCTAssertEqual(lhs, PNCounter([1, 1], [1, 1]))
        XCTAssertEqual(lhs.value, 0)
    }

    func testMerge_mergeDifferentLength_normalizeToMaxLength() {
        var lhsLess = PNCounter([3], [3])
        var lhsGreater = PNCounter([2, 1, 2], [2, 1, 2])
        let rhs = PNCounter([1, 1], [1, 1])

        lhsLess.merge(rhs)
        lhsGreater.merge(rhs)

        XCTAssertEqual(lhsLess, PNCounter([3, 1], [3, 1]))
        XCTAssertEqual(lhsLess.value, 0)

        XCTAssertEqual(lhsGreater, PNCounter([2, 1, 2], [2, 1, 2]))
        XCTAssertEqual(lhsGreater.value, 0)
    }

    // MARK: - hasConflict

    func testHasConflict_concurrentChanges_true() {
        let lhs = PNCounter([1, 2], [2, 1])
        let rhs1 = PNCounter([2, 1], [2, 1])
        let rhs2 = PNCounter([2, 1], [1, 2])
        let rhs3 = PNCounter([1, 2], [1, 2])

        XCTAssertTrue(lhs.hasConflict(with: rhs1))
        XCTAssertTrue(lhs.hasConflict(with: rhs2))
        XCTAssertTrue(lhs.hasConflict(with: rhs3))
    }

    func testHasConflict_sequentialChange_false() {
        let lhs = PNCounter([1, 2], [1, 2])
        let rhs1 = PNCounter([0, 2], [1, 2])
        let rhs2 = PNCounter([1, 2], [0, 2])
        let rhs3 = PNCounter([1, 2], [1, 2])
        let rhs4 = PNCounter([1, 3], [1, 2])
        let rhs5 = PNCounter([1, 2], [1, 3])
        let rhs6 = PNCounter([1, 3], [1, 3])

        XCTAssertFalse(lhs.hasConflict(with: rhs1))
        XCTAssertFalse(lhs.hasConflict(with: rhs2))
        XCTAssertFalse(lhs.hasConflict(with: rhs3))
        XCTAssertFalse(lhs.hasConflict(with: rhs4))
        XCTAssertFalse(lhs.hasConflict(with: rhs5))
        XCTAssertFalse(lhs.hasConflict(with: rhs6))
    }

    // MARK: - Compare

    func testCompare_compare_byComponents() {
        testCompare(expectedResult: [
            true,
            false,
            false,
            false,
            false,
        ], comparator: <)

        testCompare(expectedResult: [
            true,
            false,
            true,
            false,
            false,
        ], comparator: <=)

        testCompare(expectedResult: [
            false,
            false,
            false,
            true,
            false,
        ], comparator: >)

        testCompare(expectedResult: [
            false,
            false,
            true,
            true,
            false,
        ], comparator: >=)
    }

    private func testCompare(expectedResult: [Bool], comparator: (PNCounter, PNCounter) -> Bool) {
        let comparePairs: [(lhs: PNCounter, rhs: PNCounter)] = [
            (.init([1, 2, 3], [1, 2, 3]), .init([2, 3, 4], [2, 3, 4])),
            (.init([1, 2, 3], [1, 2, 3]), .init([2, 1, 4], [2, 1, 4])),
            (.init([1, 2, 3], [1, 2, 3]), .init([1, 2, 3], [1, 2, 3])),
            (.init([1, 2, 3], [1, 2, 3]), .init([1, 0, 3], [1, 0, 3])),
            (.init([1, 2, 3], [1, 2, 3]), .init([1, 0, 3], [2, 3, 4])),
        ]

        let actualResults = comparePairs.reduce(into: []) { result, pair in
            result.append(comparator(pair.lhs, pair.rhs))
        }

        XCTAssertEqual(actualResults, expectedResult)
    }
}

extension PNCounter {
    init(_ increment: GCounter, _ decrement: GCounter) {
        self.init()
        self.incrementCounter = increment
        self.decrementCounter = decrement
    }
}
