//
//  TPSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public struct TPSet<T: Hashable>: CRDTRemovableSet where T: Codable {
    #warning("Is it possible to omit line below?")
    public typealias Element = T

    public var value: Set<T> {
        return addedValues.subtracting(removedValues)
    }
    var addedValues: Set<T>
    var removedValues: Set<T>

    public init() {
        addedValues = []
        removedValues = []
    }

    public init(arrayLiteral elements: Element...) {
        self.init()
        addedValues = Set(elements)
    }

    @discardableResult
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        return addedValues.insert(newMember)
    }

    @discardableResult
    public mutating func remove(_ member: T) -> T? {
        if addedValues.contains(member), !removedValues.contains(member) {
            removedValues.insert(member)
            return member
        }
        return nil
    }

    public mutating func merge(_ set: TPSet<T>) {
        addedValues.formUnion(set.addedValues)
        removedValues.formUnion(set.removedValues)
    }

    public func hasConflict(with crdt: TPSet<T>) -> Bool {
        return false
    }
}

// MARK: - Comparable

extension TPSet {
    public static func < (lhs: TPSet<T>, rhs: TPSet<T>) -> Bool {
        return lhs <= rhs && lhs != rhs
    }

    public static func <= (lhs: TPSet<T>, rhs: TPSet<T>) -> Bool {
        return lhs.addedValues.isSubset(of: rhs.addedValues)
            || lhs.removedValues.isSubset(of: rhs.removedValues)
    }

    public static func > (lhs: TPSet<T>, rhs: TPSet<T>) -> Bool {
        return lhs >= rhs && lhs != rhs
    }

    public static func >= (lhs: TPSet<T>, rhs: TPSet<T>) -> Bool {
        return lhs.addedValues.isSuperset(of: rhs.addedValues)
            || lhs.removedValues.isSuperset(of: rhs.removedValues)
    }
}

// MARK: - Equatable

extension TPSet {
    public static func == (lhs: TPSet<T>, rhs: TPSet<T>) -> Bool {
        return lhs.addedValues == rhs.addedValues
            && lhs.removedValues == rhs.removedValues
    }
}
