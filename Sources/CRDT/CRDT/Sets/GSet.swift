//
//  GSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 18.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public struct GSet<T: Hashable>: CRDTSet where T: Codable {
    #warning("Is it possible to omit line below?")
    public typealias Element = T

    public internal(set) var value: Set<T>

    public init() {
        value = []
    }

    public init(arrayLiteral elements: T...) {
        value = Set(elements)
    }

    @discardableResult
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        return value.insert(newMember)
    }

    @discardableResult
    public mutating func remove(_ member: T) -> T? {
        assertionFailure("Remove shouldn't be called on `GSet`")
        return nil
    }

    public mutating func merge(_ crdt: GSet<T>) {
        value.formUnion(crdt.value)
    }

    public func hasConflict(with crdt: GSet<T>) -> Bool {
        return false
    }
}

// MARK: - Comparable

extension GSet: Comparable {
    public static func < (lhs: GSet<T>, rhs: GSet<T>) -> Bool {
        return lhs.value.isStrictSubset(of: rhs.value)
    }

    public static func <= (lhs: GSet<T>, rhs: GSet<T>) -> Bool {
        return lhs.value.isSubset(of: rhs.value)
    }

    public static func > (lhs: GSet<T>, rhs: GSet<T>) -> Bool {
        return lhs.value.isStrictSuperset(of: rhs.value)
    }

    public static func >= (lhs: GSet<T>, rhs: GSet<T>) -> Bool {
        return lhs.value.isSuperset(of: rhs.value)
    }
}

// MARK: - Equatable

extension GSet: Equatable {
    public static func == (lhs: GSet<T>, rhs: GSet<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
