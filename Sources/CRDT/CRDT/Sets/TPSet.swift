//
//  TPSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public struct TPSet<T: Hashable>: CRDTMutableSet {
    #warning("need to think")
    public typealias Element = T

    public internal(set) var replicaNumber: Int = 0

    public internal(set) var value: Set<T>
    var addedValues: Set<T>
    var removedValues: Set<T>

    public init() {
        value = []
        addedValues = []
        removedValues = []
    }

    public init(arrayLiteral elements: Element...) {
        self.init()
        value = Set(elements)
        addedValues = value
    }

    public mutating func insert(_ element: T) {
        addedValues.insert(element)
        if !removedValues.contains(element) {
            value.insert(element)
        }
    }

    public mutating func remove(_ member: T) -> T? {
        if addedValues.contains(member), !removedValues.contains(member) {
            removedValues.insert(member)
            return value.remove(member)
        }

        return nil
    }

    public mutating func merge(_ set: TPSet<T>) {
        addedValues.formUnion(set.addedValues)
        removedValues.formUnion(set.removedValues)
        value = addedValues.subtracting(removedValues)
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
