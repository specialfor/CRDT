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
    }

    // MARK: - Assign

    func testAssign_sameArgument_nothingChanges() {
        var set: ORSet<Int> = [1, 2]

        set.assign([1, 2])

        XCTAssertEqual(set.value, [1, 2])
    }

    func testAssign_disjointArgument_replace() {
        var set: ORSet<Int> = [1, 2]

        set.assign([3, 4])

        XCTAssertEqual(set.value, [3, 4])
    }

    func testAssign_semiDisjointArgument_keepIntersectionOtherReplace() {
        var set: ORSet<Int> = [1, 2]

        set.assign([2, 3])

        XCTAssertEqual(set.value, [2, 3])
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
    }

    func testMerge_concurrentAddRemove_onGeneratedHashableStruct() {
        let struct1: MGHStruct = .init(id: 1, payload: [1, 2])
        let struct2: MGHStruct = .init(id: 2, payload: [3, 4])

        var set: ORSet<MGHStruct> = [struct1, struct2]

        var set2 = set

        set.insert(struct2)
        set2.remove(struct1)
        set2.remove(struct2)

        let result = set.merging(set2)

        XCTAssertEqual(result.value, [struct2])
    }

    func testMerge_concurrentAddRemove_onOwndHashableStruct() {
        var set: ORSet<MOHStruct> = [
            .init(id: 1, payload: [1, 2]),
            .init(id: 2, payload: [3, 4])
        ]

        var set2 = set

        set.insert(.init(id: 2, payload: [3, 4]))
        set2.remove(.init(id: 1, payload: [1, 2]))
        set2.remove(.init(id: 2, payload: [3, 4]))

        let result = set.merging(set2)

        XCTAssertEqual(result.value, [.init(id: 2, payload: [3, 4])])
    }

    func testMerger_concurrentUpdates_onOwnHashableStruct() {
        var set: ORSet<MOHStruct> = [
            .init(id: 1, payload: [1, 2]),
            .init(id: 2, payload: [3, 4]),
        ]
        var set2 = set

        set.update(with: .init(id: 1, payload: [1, 3, 4]))
        set2.update(with: .init(id: 1, payload: [5]))

        let result = set.merging(set2)

        XCTAssertEqual(result.value, [
            .init(id: 1, payload: [1, 3, 4, 5]),
            .init(id: 2, payload: [3, 4])
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
        XCTAssertFalse(set3 > set5)

        // >=
        XCTAssertGreaterThanOrEqual(set1, set0)
        XCTAssertGreaterThanOrEqual(set2, set1)
        XCTAssertGreaterThanOrEqual(set2, set2)
        XCTAssertGreaterThanOrEqual(set3, set2)
        XCTAssertGreaterThanOrEqual(set4, set2)
        XCTAssertFalse(set4 >= set3)
        XCTAssertGreaterThanOrEqual(set5, set4)
        XCTAssertFalse(set3 >= set5)
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
        XCTAssertNil(result1)
        XCTAssertEqual(result2, 2)
    }

    // MARK: - Update

    func testUpdate_withPrimitites() {
        var set: ORSet<Int> = [1]

        let result1 = set.update(with: 1)
        let result2 = set.update(with: 2)

        XCTAssertEqual(set.value, [1, 2])
        XCTAssertEqual(result1, 1)
        XCTAssertNil(result2)
    }

    func testUpdate_withGeneratedHashableStruct() {
        let struct1 = MGHStruct(id: 1, payload: [1, 2])
        var set: ORSet<MGHStruct> = [struct1]

        let result1 = set.update(with: struct1)

        let struct2 = MGHStruct(id: 1, payload: [1, 2, 3])
        let result2 = set.update(with: struct2)

        let struct3 = MGHStruct(id: 2, payload: [1, 2, 3])
        let result3 = set.update(with: struct3)

        XCTAssertEqual(set.value, [
            struct1,
            struct2,
            struct3,
        ])
        XCTAssertEqual(result1, struct1)
        XCTAssertNil(result2)
        XCTAssertNil(result3)
    }

    func testUpdate_withOwnHashableStruct() {
        var set: ORSet<MOHStruct> = [.init(id: 1, payload: [1, 2])]

        let result1 = set.update(with: .init(id: 1, payload: [1, 2]))
        let result2 = set.update(with: .init(id: 1, payload: [1, 2, 3]))
        let result3 = set.update(with: .init(id: 2, payload: [1, 2]))

        XCTAssertEqual(set.value, [
            .init(id: 1, payload: [1, 2, 3]),
            .init(id: 2, payload: [1, 2]),
        ])
        XCTAssertEqual(result1, .init(id: 1, payload: [1, 2]))
        XCTAssertEqual(result2, .init(id: 1, payload: [1, 2, 3]))
        XCTAssertNil(result3)
    }
}
