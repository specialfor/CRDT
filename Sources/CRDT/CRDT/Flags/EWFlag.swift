//
//  EWFlag.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 20.04.2020.
//

public struct EWFlag: CRDT {
    public var value: Bool {
        get {
            return payload.value.contains(true)
        }
        set {
            payload.remove(!newValue)
            payload.insert(newValue)
        }
    }
    var payload: AWSet<Bool> = [false]

    public init() {}

    public init(_ value: Bool) {
        self.value = value
    }

    public mutating func merge(_ flag: Self) {
        payload.merge(flag.payload)
    }

    public func hasConflict(with crdt: Self) -> Bool {
        return false
    }
}

// MARK: - Expresssible

extension EWFlag: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        payload = [value]
    }
}

// MARK: - Comparable

#warning("Need to rethink Comparable and Equatable implementaions")
extension EWFlag: Comparable {
    public static func < (lhs: EWFlag, rhs: EWFlag) -> Bool {
        return lhs.payload < rhs.payload
    }

    public static func <= (lhs: EWFlag, rhs: EWFlag) -> Bool {
        return lhs.payload <= rhs.payload
    }

    public static func > (lhs: EWFlag, rhs: EWFlag) -> Bool {
        return lhs.payload > rhs.payload
    }

    public static func >= (lhs: EWFlag, rhs: EWFlag) -> Bool {
        return lhs.payload >= rhs.payload
    }
}

// MARK: - Equatable

extension EWFlag: Equatable {
    public static func == (lhs: EWFlag, rhs: EWFlag) -> Bool {
        return lhs.payload == rhs.payload
    }
}

// MARK: - Codable

extension EWFlag: Codable {}
