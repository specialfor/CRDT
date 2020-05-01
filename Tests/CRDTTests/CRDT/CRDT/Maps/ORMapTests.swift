//
//  ORMapTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 20.04.2020.
//

import XCTest

@testable import CRDT

final class ORMapTests: TestCase {

    // MARK: - Init

    func testInit_default_equalsEmpty() {
        let map = ORMap<Int, Int>()
        XCTAssertEqual(map.value, [:])
    }

    func testInit_expressibleByDictionaryLiteral_equalsLiteral() {
        let map: ORMap<Int, Int> = [
            1: 2,
            2: 3,
        ]

        XCTAssertEqual(map.value, [
            1: 2,
            2: 3,
        ])
    }

    // MARK: - Subscript

    func testSubscript() {
        var map: ORMap<Int, Int> = [:]
        XCTAssertNil(map[1])
        XCTAssertEqual(map.value, [:])

        map[1] = 1
        XCTAssertEqual(map[1], 1)
        XCTAssertEqual(map.value, [1: 1])

        map[1] = 1
        XCTAssertEqual(map[1], 1)
        XCTAssertEqual(map.value, [1: 1])

        map[1] = 2
        XCTAssertEqual(map[1], 2)
        XCTAssertEqual(map.value, [1: 2])

        map[1] = nil
        XCTAssertNil(map[1])
        XCTAssertEqual(map.value, [:])
    }

    // MARK: - Merge

    func testMerge() {
        var map1: ORMap<Int, Int> = [1: 1]
        var map2 = map1

        map1[2] = 2
        map1[1] = 3

        map2[1] = nil

        let result = map1.merging(map2)

        XCTAssertEqual(result.value, [
            1: 3,
            2: 2,
        ])
    }

    // MARK: - HasConflict

    func testHasConflict() {
        var map1: ORMap<Int, Int> = [1: 1]
        var map2 = map1

        map1[2] = 2
        map1[1] = 3

        map2[1] = nil

        XCTAssertFalse(map1.hasConflict(with: [:]))
        XCTAssertFalse(map1.hasConflict(with: map1))
        XCTAssertFalse(map1.hasConflict(with: map2))
        XCTAssertFalse(map2.hasConflict(with: [:]))
        XCTAssertFalse(map2.hasConflict(with: map2))
    }
}
