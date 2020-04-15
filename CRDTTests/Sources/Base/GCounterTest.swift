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

    // MARK: - Increment

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

    // MARK: - Update

    func testUpdate_calls_increment() {
        var counter: GCounter = [3, 2, 0]
        counter.replicaNumber = 2

        counter.update()

        XCTAssertEqual(counter.vector, [3, 2, 1])
    }

    // MARK: - Merge

    func testMerge_merge_byMaxComponent() {
        var lhs: GCounter = [3, 2, 1]

        lhs.merge([1, 4, 3])

        XCTAssertEqual(lhs.vector, [3, 4, 3])
        XCTAssertEqual(lhs.value, 10)
    }

    func testMerge_mergeDifferentLength_normalizeToMaxLength() {
        var lhsLess: GCounter = [1, 2, 3]
        var lhsGreater: GCounter = [1, 2, 3, 4, 5]
        let rhs: GCounter = [4, 3, 2, 1]

        lhsLess.merge(rhs)
        lhsGreater.merge(rhs)

        XCTAssertEqual(lhsLess.vector, [4, 3, 3, 1])
        XCTAssertEqual(lhsLess.value, 11)

        XCTAssertEqual(lhsGreater, [4, 3, 3, 4, 5])
        XCTAssertEqual(lhsGreater.value, 19)
    }

    // MARK: - hasConflict

    func testHasConflict_concurrentChanges_true() {
        let lhs: GCounter = [1, 2]
        let rhs: GCounter = [2, 1]

        XCTAssertTrue(lhs.hasConflict(with: rhs))
        XCTAssertTrue(rhs.hasConflict(with: lhs))
    }

    func testHasConflict_sequentialChange_false() {
        let lhs: GCounter = [1, 2]
        let rhs1: GCounter = [0, 1]
        let rhs2: GCounter = [2, 3]
        let rhs3: GCounter = [1, 2]

        XCTAssertFalse(lhs.hasConflict(with: rhs1))
        XCTAssertFalse(lhs.hasConflict(with: rhs2))
        XCTAssertFalse(lhs.hasConflict(with: rhs3))

        XCTAssertFalse(rhs1.hasConflict(with: lhs))
        XCTAssertFalse(rhs2.hasConflict(with: lhs))
        XCTAssertFalse(rhs3.hasConflict(with: lhs))
    }

    // MARK: - Compare

    func testCompare_compare_byComponents() {
        let pairs: [(lhs: GCounter, rhs: GCounter)] = [
            ([1, 2, 3], [2, 3, 4]),
            ([1, 2, 3], [2, 1, 4]),
            ([1, 2, 3], [1, 2, 3]),
        ]

        let expectedResult = [
            true,
            false,
            false
        ]

        let actualResults = pairs.reduce(into: []) { result, pair in
            result.append(pair.lhs < pair.rhs)
        }

        XCTAssertEqual(actualResults, expectedResult)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension GCounter: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Int...) {
        self.init()
        self.vector = elements
    }
}
