//
//  Assert.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

var assertionFailureClosure = defaultAssertionFailureClosure
var defaultAssertionFailureClosure = Swift.assertionFailure

func assertionFailure(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
    assertionFailureClosure(message(), file, line)
}
