//
//  TestCase.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

import XCTest

@testable import CRDT

class TestCase: XCTestCase {
    private(set) var assertionFailureExpectation: XCTestExpectation!

    override func setUp() {
        assertionFailureExpectation = XCTestExpectation()
        assertionFailureClosure = { [weak self] _, _, _ in
            self?.assertionFailureExpectation.fulfill()
        }
    }

    override func tearDown() {
        assertionFailureClosure = defaultAssertionFailureClosure
    }

    func assertFullfilledExpectation(_ expectation: XCTestExpectation) {
        wait(for: [expectation], timeout: 1)
    }
}
