//
//  TPSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public struct TPSet<T: Hashable>: CRDTSet {
    #warning("need to think")
    public typealias Element = T

    public internal(set) var replicaNumber: Int = 0

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

// MARK: - SetAlgebra

extension TPSet: SetAlgebra {
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        return addedValues.insert(newMember)
    }

    public mutating func update(with newMember: __owned T) -> T? {
        let result = insert(newMember)
        return result.inserted ? newMember : nil
    }

    public mutating func remove(_ member: T) -> T? {
        if addedValues.contains(member), !removedValues.contains(member) {
            removedValues.insert(member)
            return member
        }
        return nil
    }

    public mutating func formUnion(_ other: TPSet<T>) {
        addedValues.formUnion(other.addedValues)
        removedValues.formIntersection(other.removedValues)
    }

    public mutating func formIntersection(_ other: TPSet<T>) {
        addedValues.formIntersection(other.addedValues)
        removedValues.formUnion(other.removedValues)
    }

    public mutating func formSymmetricDifference(_ other: TPSet<T>) {
        let union = self.union(other)
        let intersection = self.intersection(other)
        self = union.subtracting(intersection)
    }
}
