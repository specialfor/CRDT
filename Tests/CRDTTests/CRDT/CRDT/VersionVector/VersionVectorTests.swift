//
//  VersionVectorTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 16.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class VersionVectorTests: XCTestCase {

    #warning("Should be implementes as assertion")
//    func testIncrement_replicaNumberGreaterThanUnderlyingVectorLength_fail() {
//        var counter: GCounter = []
//        counter.replicaNumber = 1
//
//        counter.increment()
//    }

    // MARK: - Init

    func testInit_setElements_fromArgument() {
        let first = VersionVector([1, 2, 3])
        let second: VersionVector = [3, 2, 1]

        XCTAssertEqual(first, [1, 2, 3])
        XCTAssertEqual(second, [3, 2, 1])
    }

    // MARK: - Merge

    func testMerge_merge_byMaxComponent() {
        var lhs: VersionVector = [3, 2, 1]

        lhs.merge([1, 4, 3])

        XCTAssertEqual(lhs.elements, [3, 4, 3])
    }

    func testMerge_mergeDifferentLength_normalizeToMaxLength() {
        var lhsLess: VersionVector = [1, 2, 3]
        var lhsGreater: VersionVector = [1, 2, 3, 4, 5]
        let rhs: VersionVector = [4, 3, 2, 1]

        lhsLess.merge(rhs)
        lhsGreater.merge(rhs)

        XCTAssertEqual(lhsLess.elements, [4, 3, 3, 1])
        XCTAssertEqual(lhsGreater.elements, [4, 3, 3, 4, 5])
    }

    func testMerging_merge_byMaxComponent() {
        let lhs: VersionVector = [3, 2, 1]

        let actualResult = lhs.merging([1, 4, 3])

        XCTAssertEqual(actualResult, [3, 4, 3])
    }

    func testMerging_mergeDifferentLength_normalizeToMaxLength() {
        let lhsLess: VersionVector = [1, 2, 3]
        let lhsGreater: VersionVector = [1, 2, 3, 4, 5]
        let rhs: VersionVector = [4, 3, 2, 1]

        let actualLessResult = lhsLess.merging(rhs)
        let actualGreaterResult = lhsGreater.merging(rhs)

        XCTAssertEqual(actualLessResult.elements, [4, 3, 3, 1])
        XCTAssertEqual(actualGreaterResult.elements, [4, 3, 3, 4, 5])
    }

    func testNormalize_firstArgumentLengthIsGreater_toFirstArgumentLength() {
        var first = [1, 2, 3]
        var second = [2, 2]

        VersionVector.normalize(&first, &second)

        XCTAssertEqual(first, [1, 2, 3])
        XCTAssertEqual(second, [2, 2, 0])
    }

    func testNormalize_firstArgumentLengthIsLess_toSecondArgumentLength() {
        var first = [1, 2]
        var second = [2, 2, 3]

        VersionVector.normalize(&first, &second)

        XCTAssertEqual(first, [1, 2, 0])
        XCTAssertEqual(second, [2, 2, 3])
    }

    func testNormalize_argumentsLengthAreEqual_doNothing() {
        var first = [1, 2, 3]
        var second = [2, 2, 3]

        VersionVector.normalize(&first, &second)

        XCTAssertEqual(first, [1, 2, 3])
        XCTAssertEqual(second, [2, 2, 3])
    }

    // MARK: - hasConflict

    func testHasConflict_concurrentChanges_true() {
        let lhs: VersionVector = [1, 2]
        let rhs: VersionVector = [2, 1]

        XCTAssertTrue(lhs.hasConflict(with: rhs))
    }

    func testHasConflict_sequentialChange_false() {
        let lhs: VersionVector = [1, 2]
        let rhs1: VersionVector = [0, 2]
        let rhs2: VersionVector = [2, 3]
        let rhs3: VersionVector = [1, 2]

        XCTAssertFalse(lhs.hasConflict(with: rhs1))
        XCTAssertFalse(lhs.hasConflict(with: rhs2))
        XCTAssertFalse(lhs.hasConflict(with: rhs3))
    }

    // MARK: - Collection

    func testCollectionConforming_onEmpty() {
        let vector: VersionVector = []

        XCTAssertEqual(vector.startIndex, 0)
        XCTAssertEqual(vector.endIndex, 0)
        XCTAssertEqual(vector.index(after: vector.startIndex), 1)
    }

    func testCollectionConforming_onNonEmpty() {
        let elements = [1, 2, 3]
        var vector = VersionVector(elements)

        vector[1] = 10

        XCTAssertEqual(vector.startIndex, 0)
        XCTAssertEqual(vector.endIndex, elements.count)
        XCTAssertEqual(vector.index(after: 1), 2)

        XCTAssertEqual(vector[2], elements[2])
        XCTAssertEqual(vector[1], 10)
    }

    // MARK: - BidirecctionCollection

    func testBidirecctionCollection_onEmpty() {
        let vector: VersionVector = []

        XCTAssertEqual(vector.index(before: vector.endIndex), -1)
    }

    func testBidirecctionCollection_onNonEmpty() {
        let vector: VersionVector = [1, 2, 3]

        XCTAssertEqual(vector.index(before: vector.endIndex), 2)
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

    private func testCompare(expectedResult: [Bool],
                             comparator: (VersionVector, VersionVector) -> Bool) {
        let comparePairs: [(lhs: VersionVector, rhs: VersionVector)] = [
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
