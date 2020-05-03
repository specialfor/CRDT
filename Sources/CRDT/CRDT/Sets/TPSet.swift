//
//  TPSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public struct TPSet<T: Hashable>: CRDTRemovableSet {
    #warning("Is it possible to omit line below?")
    public typealias Element = T

    public private(set) var value: Set<T>
    var addedValues: Set<T>
    var removedValues: Set<T>

    public init() {
        addedValues = []
        removedValues = []
        value = []
    }

    public init(arrayLiteral elements: Element...) {
        self.init()
        addedValues = Set(elements)
        value = addedValues
    }

    @discardableResult
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        defer {
            if !removedValues.contains(newMember) {
                value.insert(newMember)
            }
        }
        return addedValues.insert(newMember)
    }

    @discardableResult
    public mutating func remove(_ member: T) -> T? {
        if addedValues.contains(member), !removedValues.contains(member) {
            removedValues.insert(member)
            value.remove(member)
            return member
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

// MARK: - Codable

extension TPSet: Codable where T: Codable {
    private enum CodingKeys: String, CodingKey {
        case addedValues
        case removedValues
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        addedValues = try container.decode(Set<T>.self, forKey: .addedValues)
        removedValues = try container.decode(Set<T>.self, forKey: .removedValues)
        value = addedValues.subtracting(removedValues)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(addedValues, forKey: .addedValues)
        try container.encode(removedValues, forKey: .removedValues)
    }
}
