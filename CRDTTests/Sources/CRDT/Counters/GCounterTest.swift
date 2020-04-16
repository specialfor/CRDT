//
//  GCounterTest.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class GCounterTest: XCTestCase {

    // MARK: - Value

    func testValue_calculates_correctly() {
        let counter: GCounter = [1, 3, 5, 2, 0]
        XCTAssert(counter.value == 11)
    }

    // MARK: - Update

    func testIncrement_incement_correctElement() {
        let replicaNumber = 2
        var counter: GCounter = [3, 2, 0]
        counter.replicaNumber = replicaNumber

        counter.increment()

        XCTAssertEqual(counter.vector, [3, 2, 1])
    }

    func testIncrement_increment_byOne() {
        var counter: GCounter = [3, 2, 0]
        counter.replicaNumber = 2

        counter.increment()
        counter.increment()
        counter.increment()

        XCTAssertEqual(counter.vector, [3, 2, 3])
    }

    #warning("need to think")
//    func testIncrement_replicaNumberGreaterThanUnderlyingVectorLength_fail() {
//        var counter: GCounter = []
//        counter.replicaNumber = 1
//
//        counter.increment()
//    }

    // MARK: - Merge

    func testMerge_success() {
        var lhs1: GCounter = [3, 2, 1]
        var lhs2: GCounter = [1, 2, 3]
        var lhs3: GCounter = [1, 2, 3, 4, 5]

        let rhs1: GCounter = [1, 4, 3]
        let rhs23: GCounter = [4, 3, 2, 1]

        lhs1.merge(rhs1)
        lhs2.merge(rhs23)
        lhs3.merge(rhs23)

        XCTAssertEqual(lhs1, [3, 4, 3])
        XCTAssertEqual(lhs2, [4, 3, 3, 1])
        XCTAssertEqual(lhs3, [4, 3, 3, 4, 5])
    }

    // MARK: - hasConflict

    func testHasConflict_concurrentChanges_true() {
        let lhs: GCounter = [1, 2]
        let rhs: GCounter = [2, 1]

        XCTAssertTrue(lhs.hasConflict(with: rhs))
    }

    func testHasConflict_sequentialChange_false() {
        let lhs: GCounter = [1, 2]
        let rhs1: GCounter = [0, 2]
        let rhs2: GCounter = [2, 3]
        let rhs3: GCounter = [1, 2]

        XCTAssertFalse(lhs.hasConflict(with: rhs1))
        XCTAssertFalse(lhs.hasConflict(with: rhs2))
        XCTAssertFalse(lhs.hasConflict(with: rhs3))
    }

    // MARK: - Compare

    func testCompare_less_byComponents() {
        testCompare(expectedResult: [
            true,
            false,
            false,
            false,
        ], comparator: <)
    }

    func testCompare_lessOrEqual_byComponents() {
        testCompare(expectedResult: [
            true,
            false,
            true,
            false,
        ], comparator: <=)
    }

    func testCompare_greater_byComponents() {
        testCompare(expectedResult: [
            false,
            false,
            false,
            true,
        ], comparator: >)
    }

    func testCompare_greaterOrEqual_byComponents() {
        testCompare(expectedResult: [
            false,
            false,
            true,
            true,
        ], comparator: >=)
    }

    private func testCompare(expectedResult: [Bool], comparator: (GCounter, GCounter) -> Bool) {
        let comparePairs: [(lhs: GCounter, rhs: GCounter)] = [
            ([1, 2, 3], [2, 3, 4]),
            ([1, 2, 3], [2, 1, 4]),
            ([1, 2, 3], [1, 2, 3]),
            ([1, 2, 3], [1, 0, 3]),
        ]

        let actualResults = comparePairs.reduce(into: []) { result, pair in
            result.append(comparator(pair.lhs, pair.rhs))
        }

        XCTAssertEqual(actualResults, expectedResult)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension GCounter: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Int...) {
        self.init()
        self.vector = VersionVector(elements)
    }
}
