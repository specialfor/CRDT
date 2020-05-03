//
//  ORSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public struct ORSet<T: Hashable>: CRDTRemovableSet, CRDTUpdatableSet where T: Codable, T: Mergable {
    #warning("Is it possible to omit line below?")
    public typealias Element = T

    public var value: Set<T> {
        return Set(valueArray)
    }

    private var valueArray: [T] {
        payload.map { $0.value }
    }

    var payload: TPSet<Pair>

    public init() {
        payload = []
    }

    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }

    public init<U: Sequence>(_ sequence: U) where U.Element == T {
        payload = []
        sequence.forEach { insert($0) }
    }

    public mutating func assign(_ newValue: Set<T>) {
        guard newValue != value else {
            return
        }

        let newValueDiff = newValue.subtracting(value)
        let valueDiff = value.subtracting(newValue)

        valueDiff.forEach { remove($0) }
        newValueDiff.forEach { insert($0) }
    }

    @discardableResult
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        let isContained = contains(newMember)
        _ = payload.insert(.init(value: newMember, tag: .unique))
        return (!isContained, newMember)
    }

    @discardableResult
    public mutating func remove(_ member: T) -> T? {
        let pairs = payload.filter { $0.value == member }
        pairs.forEach { _ = payload.remove($0) }

        let isRemoved = !pairs.isEmpty
        return isRemoved ? member : nil
    }

    public mutating func merge(_ set: ORSet<T>) {
        let oldSet = self

        payload.merge(set.payload)

        let dict: [T: Set<T>] = oldSet.valueArray.reduce(into: [:]) { (result, value) in
            guard var set = result[value] else {
                result[value] = [value]
                return
            }

            set.insert(value)
            result[value] = set
        }

        dict.forEach { key, set in
            guard var value = set.first, set.count > 1 else {
                return
            }

            set.dropFirst().forEach { value.merge($0) }
            update(with: value)
        }
    }

    public func hasConflict(with crdt: ORSet<T>) -> Bool {
        return false
    }
}

// MARK: - Pair

extension ORSet {
    struct Pair: Hashable, Codable {
        let value: T
        let tag: UniqueTag
    }
}

// MARK: - Comparable

extension ORSet: Comparable {
    public static func < (lhs: ORSet<T>, rhs: ORSet<T>) -> Bool {
        return lhs.payload < rhs.payload
    }

    public static func <= (lhs: ORSet<T>, rhs: ORSet<T>) -> Bool {
        return lhs.payload <= rhs.payload
    }

    public static func > (lhs: ORSet<T>, rhs: ORSet<T>) -> Bool {
        return lhs.payload > rhs.payload
    }

    public static func >= (lhs: ORSet<T>, rhs: ORSet<T>) -> Bool {
        return lhs.payload >= rhs.payload
    }
}

// MARK: - Equatable

extension ORSet: Equatable {
    public static func == (lhs: ORSet<T>, rhs: ORSet<T>) -> Bool {
        return lhs.payload == rhs.payload
    }
}
