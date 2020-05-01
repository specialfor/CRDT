//
//  MVRegisterTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 17.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

import XCTest

@testable import CRDT

final class MVRegisterTests: TestCase {

    let deviceID: Device.ID = "123"

    override func set(stubbr: Stubbr) {
        stubbr.stub(
            getter: { Device.Dependency.generateDeviceID },
            setter: { Device.Dependency.generateDeviceID = $0 },
            stubbed: { return self.deviceID })
    }

    // MARK: - Value

    func testValue_getter_getInitedValue() {
        let register: MVRegister<String> = ["str"]
        XCTAssertEqual(register.value, [.init(value: "str", vector: .initial)])
    }

    // MARK: - Assign

    func testAssign_changeValue() {
        var register: MVRegister<String> = ["str"]

        register.assign(["aaa"])

        XCTAssertEqual(register.value, [.init(value: "aaa", vector: [deviceID: 1])])
    }

    func testAssign_setWithSameSeveralElements_changeValue() {
        var register: MVRegister<String> = ["a"]

        register.assign(["a", "b"])

        XCTAssertEqual(register.value, [
            .init(value: "a", vector: [deviceID: 1]),
            .init(value: "b", vector: [deviceID: 1]),
        ])
    }

    // MARK: - Merge

    func testMerge_hasConflict_unionBoth() {
        var lhs1 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 2,
                "device_2": 0,
            ])
        ])
        let lhs2 = lhs1

        var rhs1 = MVRegister(value: [
            .init(value: "b", vector: [
                "device_1": 1,
                "device_2": 1,
            ])
        ])
        let rhs2 = rhs1

        lhs1.merge(rhs2)
        rhs1.merge(lhs2)

        XCTAssertEqual(lhs1, MVRegister(
            value: [
                .init(value: "a", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
                .init(value: "b", vector: [
                    "device_1": 1,
                    "device_2": 1,
                ])
        ]))

        XCTAssertEqual(rhs1, MVRegister(
            value: [
                .init(value: "a", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
                .init(value: "b", vector: [
                    "device_1": 1,
                    "device_2": 1,
                ])
        ]))
    }

    func testMerge_onEmpty_equalsToMerged() {
        var lhs1 = MVRegister<String>(value: [])
        let rhs1 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 2,
                "device_2": 0,
            ])
        ])

        lhs1.merge(rhs1)

        XCTAssertEqual(lhs1, rhs1)
    }

    func testMerge_amazonIssue_removedItemExists() {
        var lhs = MVRegister(
            value: [
                .init(value: "a", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
                .init(value: "b", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
        ])
        let rhs = MVRegister(value: [
            .init(value: "c", vector: [
                "device_1": 0,
                "device_2": 1,
            ]),
        ])

        lhs.merge(rhs)

        XCTAssertEqual(lhs, MVRegister(
            value: [
                .init(value: "a", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
                .init(value: "b", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
                .init(value: "c", vector: [
                    "device_1": 0,
                    "device_2": 1,
                ]),
        ]))
    }

    func testMerge_almostAmazonIssue_overwrites() {
        var lhs = MVRegister(
            value: [
                .init(value: "a", vector:[
                    "device_1": 2,
                    "device_2": 0,
                ]),
                .init(value: "b", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
        ])
        let rhs = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 1,
                "device_2": 0,
            ]),
        ])

        lhs.merge(rhs)

        XCTAssertEqual(lhs, MVRegister(
            value: [
                .init(value: "a", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
                .init(value: "b", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
        ]))
    }

        // MARK: - HasConflict

        func testHasConflict() {
            let lhs1 = MVRegister(value: [
                .init(value: "a", vector: [
                    "device_1": 1,
                    "device_2": 0,
                ]),
            ])
            let lhs2 = MVRegister(value: [
                .init(value: "a", vector: [
                    "device_1": 1,
                    "device_2": 0,
                ]),
                .init(value: "c", vector: [
                    "device_1": 0,
                    "device_2": 1,
                ]),
            ])
            let lhs3 = MVRegister(value: [
                .init(value: "a", vector: [
                    "device_1": 1,
                    "device_2": 0,
                ]),
                .init(value: "y", vector: [
                    "device_1": 1,
                    "device_2": 0,
                ]),
            ])

            let rhs = MVRegister(value: [
                .init(value: "d", vector: [
                    "device_1": 1,
                    "device_2": 1,
                ]),
                .init(value: "e", vector: [
                    "device_1": 1,
                    "device_2": 2,
                ]),
            ])
            let rhs2 = MVRegister(value: [
                .init(value: "f", vector: [
                    "device_1": 0,
                    "device_2": 1,
                ]),
            ])
            let rhs3 = MVRegister(value: [
                .init(value: "a", vector: [
                    "device_1": 0,
                    "device_2": 1,
                ]),
            ])
            let rhs4 = MVRegister(value: [
                .init(value: "a", vector: [
                    "device_1": 2,
                    "device_2": 0,
                ]),
            ])
            let rhs5 = MVRegister(value: [
                .init(value: "d", vector: [
                    "device_1": 0,
                    "device_2": 1,
                ]),
                .init(value: "e", vector: [
                    "device_1": 0,
                    "device_2": 1,
                ]),
            ])

            XCTAssertFalse(lhs1.hasConflict(with: lhs1))
            XCTAssertFalse(lhs1.hasConflict(with: lhs2))
            XCTAssertFalse(lhs1.hasConflict(with: rhs))
            XCTAssertFalse(lhs1.hasConflict(with: rhs4))
            XCTAssertFalse(lhs2.hasConflict(with: rhs))
            XCTAssertFalse(rhs.hasConflict(with: rhs5))
            XCTAssertFalse(rhs.hasConflict(with: lhs3))

            XCTAssertTrue(lhs1.hasConflict(with: rhs2))
            XCTAssertTrue(lhs1.hasConflict(with: rhs3))
            XCTAssertTrue(lhs3.hasConflict(with: rhs5))
            XCTAssertTrue(lhs2.hasConflict(with: lhs3))
        }

    // MARK: - Compare

    func testCompare() {
        let lhs1 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 1,
                "device_2": 0,
            ]),
        ])
        let lhs2 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 1,
                "device_2": 0,
            ]),
            .init(value: "c", vector: [
                "device_1": 0,
                "device_2": 1,
            ]),
        ])
        let lhs3 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 1,
                "device_2": 0,
            ]),
            .init(value: "y", vector: [
                "device_1": 1,
                "device_2": 0,
            ]),
        ])

        let rhs = MVRegister(value: [
            .init(value: "d", vector: [
                "device_1": 1,
                "device_2": 1,
            ]),
            .init(value: "e", vector: [
                "device_1": 1,
                "device_2": 2,
            ]),
        ])
        let rhs2 = MVRegister(value: [
            .init(value: "f", vector: [
                "device_1": 0,
                "device_2": 1,
                "device_3": 2,
            ]),
        ])
        let rhs3 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 0,
                "device_2": 1,
            ]),
        ])
        let rhs4 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 2,
                "device_2": 0,
                "device_3": 10,
            ]),
        ])

        // <
        XCTAssertLessThan(lhs1, rhs)
        XCTAssertLessThan(lhs1, lhs2)
        XCTAssertFalse(lhs1 < lhs1)
        XCTAssertFalse(lhs1 < rhs2)
        XCTAssertFalse(lhs1 < rhs3)
        XCTAssertLessThan(lhs1, rhs4)
        XCTAssertLessThan(lhs2, rhs)
        XCTAssertFalse(lhs2 < rhs2)
        XCTAssertFalse(lhs2 < lhs3)

        // <=
        XCTAssertLessThanOrEqual(lhs1, rhs)
        XCTAssertLessThanOrEqual(lhs1, lhs1)
        XCTAssertLessThanOrEqual(lhs1, lhs2)
        XCTAssertFalse(lhs1 <= rhs2)
        XCTAssertFalse(lhs1 <= rhs3)
        XCTAssertLessThanOrEqual(lhs1, rhs4)
        XCTAssertLessThanOrEqual(lhs2, rhs)
        XCTAssertFalse(lhs2 <= rhs2)
        XCTAssertFalse(lhs2 <= lhs3)

        // >
        XCTAssertGreaterThan(rhs, lhs1)
        XCTAssertGreaterThan(lhs2, lhs1)
        XCTAssertFalse(lhs1 > lhs1)
        XCTAssertFalse(lhs1 > rhs2)
        XCTAssertFalse(lhs1 > rhs3)
        XCTAssertGreaterThan(rhs, lhs2)
        XCTAssertGreaterThan(rhs4, lhs1)
        XCTAssertFalse(lhs2 > rhs2)
        XCTAssertFalse(lhs2 > lhs3)

        // >=
        XCTAssertGreaterThanOrEqual(rhs, lhs1)
        XCTAssertGreaterThanOrEqual(lhs2, lhs1)
        XCTAssertTrue(lhs1 >= lhs1)
        XCTAssertFalse(lhs1 >= rhs2)
        XCTAssertFalse(lhs1 >= rhs3)
        XCTAssertGreaterThanOrEqual(rhs, lhs2)
        XCTAssertGreaterThanOrEqual(rhs4, lhs1)
        XCTAssertFalse(lhs2 >= rhs2)
        XCTAssertFalse(lhs2 >= lhs3)
    }

    // MARK: - Equatable

    func testEqual() {
        let lhs1 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 1,
                "device_2": 0,
            ]),
        ])
        let lhs2 = MVRegister(value: [
            .init(value: "b", vector: [
                "device_1": 1,
                "device_2": 0,
            ]),
            .init(value: "c", vector: [
                "device_1": 0,
                "device_2": 1,
            ]),
        ])

        let rhs1 = MVRegister(value: [
            .init(value: "d", vector: [
                "device_1": 1,
                "device_2": 1,
            ]),
            .init(value: "e", vector: [
                "device_1": 1,
                "device_2": 2,
            ]),
        ])
        let rhs2 = MVRegister(value: [
            .init(value: "a", vector: [
                "device_1": 2,
                "device_2": 0,
                "device_3": 3,
            ]),
        ])

        XCTAssertEqual(lhs1, lhs1)
        XCTAssertEqual(lhs2, lhs2)

        XCTAssertNotEqual(lhs1, rhs1)
        XCTAssertNotEqual(lhs1, rhs2)
        XCTAssertNotEqual(lhs2, rhs1)
        XCTAssertNotEqual(lhs2, rhs2)
        XCTAssertNotEqual(lhs1, lhs2)
    }
}
