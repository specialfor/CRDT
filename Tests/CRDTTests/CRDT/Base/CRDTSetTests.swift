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

    // MARK: - Union

    func testUnion_withSame_equalsSame() {
        let set: some CRDTSet = [1, 2] as GSet<Int>
        XCTAssertEqual(set.union(set).value, set.value)
    }

    func testUnion_withEmpty_equalInitial() {
        let set: some CRDTSet = [1, 2] as GSet<Int>
        XCTAssertEqual(set.union([]).value, set.value)
    }

    func testUnion_withDifferent_equalsUnion() {
        let lhs: GSet = [1, 2]
        let rhs: GSet = [3]

        XCTAssertEqual(lhs.union(rhs), [1, 2, 3])
    }

    // MARK: - Intersection

    func testIntersection_withSame_equalsSame() {
        let set: some CRDTSet = [1, 2] as GSet<Int>
        XCTAssertEqual(set.intersection(set).value, set.value)
    }

    func testIntersection_withEmpty_equalsEmpty() {
        let set: some CRDTSet = [1, 2] as GSet<Int>
        XCTAssertEqual(set.intersection([]).value, [])
    }

    func testIntersection_withSuperset_equalInitial() {
        let lhs: GSet = [1, 2]
        let rhs: GSet = [1, 2, 3]

        XCTAssertEqual(lhs.intersection(rhs), [1, 2])
    }

    func testIntersection_withDisjoint_equalsEmpty() {
        let lhs: GSet = [1, 2]
        let rhs: GSet = [3]

        XCTAssertEqual(lhs.intersection(rhs), [])
    }

    // MARK: - SymmetricDifference

    func testSymmetricDifference_withSame_equalsSame() {
        let set: some CRDTSet = [1, 2] as GSet<Int>
        XCTAssertEqual(set.symmetricDifference(set).value, [])
    }

    func testSymmetricDifference_withEmpty_equalsEmpty() {
        let set: some CRDTSet = [1, 2] as GSet<Int>
        XCTAssertEqual(set.symmetricDifference([]).value, set.value)
    }

    func testSymmetricDifference_withSuperset_equalInitial() {
        let lhs: GSet = [1, 2]
        let rhs: GSet = [1, 2, 3]

        XCTAssertEqual(lhs.symmetricDifference(rhs), [3])
    }

    func testSymmetricDifference_onDisjoints_equalsUnion() {
        let lhs: GSet = [1, 2]
        let rhs: GSet = [3]

        XCTAssertEqual(lhs.symmetricDifference(rhs), lhs.union(rhs))
    }

    // MARK: - Insert

    func testInsert_elementNotExistsInSet_success() {
        var set: GSet = [1, 2]

        let result: (inserted: Bool, memberAfterInsert: Int) = set.insert(3)

        XCTAssertEqual(set.value, Set([1, 2, 3]))
        XCTAssertTrue(result.inserted)
        XCTAssertEqual(result.memberAfterInsert, 3)
    }

    func testInsert_elementExistsInSet_failure() {
        var set: GSet = [1, 2]

        let result: (inserted: Bool, memberAfterInsert: Int) = set.insert(2)

        XCTAssertEqual(set.value, Set([1, 2]))
        XCTAssertFalse(result.inserted)
        XCTAssertEqual(result.memberAfterInsert, 2)
    }

    // MARK: - Remove

    func testRemove_existedElement_element() {
        #warning("need to replace with PNSet")
//        var set: GSet<Int> = [1, 2]
//
//        let result = set.remove(1)
//
//        XCTAssertEqual(result, 1)
//        XCTAssertEqual(set.value, Set([2]))
    }

    func testRemove_nonExistedElement_nil() {
        #warning("need to replace with PNSet")
//        var set: GSet<Int> = [1, 2]
//
//        let result = set.remove(3)
//
//        XCTAssertNil(result)
//        XCTAssertEqual(set.value, Set([1, 2]))
    }

    // MARK: - Update

    func testUpdate_existedElement_element() {
        var set: GSet = [1, 2]

        let result = set.update(with: 2)

        XCTAssertEqual(result, 2)
        XCTAssertEqual(set.value, Set([1, 2]))
    }

    func testUpdate_notExistedElement_nil() {
        var set: GSet = [1, 2]

        let result = set.update(with: 3)

        XCTAssertNil(result)
        XCTAssertEqual(set.value, Set([1, 2, 3]))
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
