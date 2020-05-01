//
//  LWWRegister.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 16.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public struct LWWRegister<T: Equatable>: CRDT where T: Codable {
    public var value: T {
        get { return _value }
        set {
            _value = newValue
            timestamp = .now
        }
    }
    private var _value: T

    public internal(set) var timestamp: Timestamp = 0

    public init(_ value: T) {
        _value = value
    }

    init(_ value: T, timestamp: Int) {
        self.init(value)
        self.timestamp = timestamp
    }

    public mutating func merge(_ register: LWWRegister<T>) {
        if timestamp <= register.timestamp {
            _value = register.value
            timestamp = register.timestamp
        }
    }

    public func hasConflict(with crdt: LWWRegister<T>) -> Bool {
        return false
    }

    // MARK: - Comparable

    public static func < (lhs: LWWRegister<T>, rhs: LWWRegister<T>) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }

    public static func <= (lhs: LWWRegister<T>, rhs: LWWRegister<T>) -> Bool {
        return lhs.timestamp < rhs.timestamp || lhs.timestamp == rhs.timestamp
    }

    public static func > (lhs: LWWRegister<T>, rhs: LWWRegister<T>) -> Bool {
        return lhs.timestamp > rhs.timestamp
    }

    public static func >= (lhs: LWWRegister<T>, rhs: LWWRegister<T>) -> Bool {
        return lhs.timestamp > rhs.timestamp || lhs.timestamp == rhs.timestamp
    }

    // MARK: - Equatable

    public static func == (lhs: LWWRegister<T>, rhs: LWWRegister<T>) -> Bool {
        return lhs.value == rhs.value
            && lhs.timestamp == rhs.timestamp
    }
}
