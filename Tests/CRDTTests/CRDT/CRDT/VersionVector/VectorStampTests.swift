//
//  VectorStampTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 01.05.2020.
//

import XCTest

@testable import CRDT

final class VectorStampTests: TestCase {
    let deviceID = "123"

    override func set(stubbr: Stubbr) {
        stubbr.stub(
            getter: { Device.Dependency.generateDeviceID },
            setter: { Device.Dependency.generateDeviceID = $0 },
            stubbed: { return self.deviceID })
    }

    // MARK: - Init

    func testInit_default_equalsEmptyDictionary() {
        let vector = VectorStamp()
        XCTAssertEqual(vector.elements, [:])
    }

    func testInit_elements_equalsArgument() {
        let dictionary = [
            "device_1": 1,
            "device_2": 2,
        ]

        let vector = VectorStamp(dictionary)

        XCTAssertEqual(vector.elements, dictionary)
    }

    func testInit_literal_equalsLiteral() {
        let vector: VectorStamp = [
            "device_1": 1,
            "device_2": 2,
        ]

        XCTAssertEqual(vector.elements, [
            "device_1": 1,
            "device_2": 2,
        ])
    }

    // MARK: - Initial

    func testInitial_equalsEmpty() {
        let vector = VectorStamp.initial
        XCTAssertEqual(vector.elements, [deviceID: 0])
    }

    // MARK: - Merge

    func testMerge_emptyArgument_equalsCaller() {
        let dictionary = [
            "device_1": 1,
            "device_2": 2,
        ]
        let vector = VectorStamp(dictionary)

        let result = vector.merging([:])

        XCTAssertEqual(result.elements, dictionary)
    }

    func testMerge_sameArgument_equalsCaller() {
        let dictionary = [
            "device_1": 1,
            "device_2": 2,
        ]
        let vector = VectorStamp(dictionary)

        let result = vector.merging(vector)

        XCTAssertEqual(result.elements, dictionary)
    }

    func testMerge_disjointArgument_equalsUnion() {
        let dictionary = [
            "device_1": 1,
            "device_2": 2,
        ]
        let vector = VectorStamp(dictionary)

        let result = vector.merging([
            "devie_3": 3,
        ])

        XCTAssertEqual(result.elements, [
            "device_1": 1,
            "device_2": 2,
            "devie_3": 3,
        ])
    }

    func testMerge_sameKeysArgument_equalsUnionByMax() {
        let dictionary = [
            "device_1": 1,
            "device_2": 2,
        ]
        let vector = VectorStamp(dictionary)

        let result = vector.merging([
            "device_1": 3,
            "device_2": 1,
        ])

        XCTAssertEqual(result.elements, [
            "device_1": 3,
            "device_2": 2,
        ])
    }

    func testMerge_argumentKeysIntersectionIsNotEmpty_equalsUnionByMax() {
        let dictionary = [
            "device_1": 1,
            "device_2": 2,
        ]
        let vector = VectorStamp(dictionary)

        let result = vector.merging([
            "device_1": 3,
            "device_3": 1,
        ])

        XCTAssertEqual(result.elements, [
            "device_1": 3,
            "device_2": 2,
            "device_3": 1,
        ])
    }

    // MARK: - HasConflict

    func testHasConflict() {
        let vector1 = VectorStamp([
            "device_1": 1,
            "device_2": 2,
        ])
        let vector2 = vector1
        let vector3 = VectorStamp(["device_3": 3])
        let vector4 = VectorStamp([
            "device_1": 3,
            "device_2": 1,
        ])
        let vector5 = VectorStamp([
            "device_1": 2,
            "device_2": 3,
        ])

        XCTAssertFalse(vector1.hasConflict(with: [:]))
        XCTAssertFalse(vector1.hasConflict(with: vector2))
        XCTAssertFalse(vector1.hasConflict(with: vector5))

        XCTAssertTrue(vector1.hasConflict(with: vector3))
        XCTAssertTrue(vector1.hasConflict(with: vector4))
        XCTAssertTrue(vector3.hasConflict(with: vector4))
        XCTAssertTrue(vector3.hasConflict(with: vector5))
        XCTAssertTrue(vector4.hasConflict(with: vector5))
    }
}

