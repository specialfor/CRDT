//
//  ORSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public struct ORSet<T: Hashable>: CRDTSet {
    #warning("need to think")
    public typealias Element = T

    public internal(set) var replicaNumber: Int = 0

    public var value: Set<T> {
        return Set(payload.map { $0.value })
    }
    var payload: TPSet<Pair>

    public init() {
        payload = []
    }

    public init(arrayLiteral elements: T...) {
        payload = []
        elements.forEach { insert($0) }
    }

    @discardableResult
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        let isContained = contains(newMember)
        _ = payload.insert(.init(value: newMember, timestamp: Timestamp.now))
        return (!isContained, newMember)
    }

    @discardableResult
    public mutating func remove(_ member: T) -> T? {
        let pairs = payload.filter { $0.value == member }
        pairs.forEach { _ = payload.remove($0) }

        let isRemoved = !pairs.isEmpty
        return isRemoved ? member : nil
    }

    @discardableResult
    public mutating func update(with newMember: T) -> T? {
        return insert(newMember).inserted ? nil : newMember
    }

    public mutating func merge(_ set: ORSet<T>) {
        payload.merge(set.payload)
    }

    public func hasConflict(with crdt: ORSet<T>) -> Bool {
        return false
    }
}

// MARK: - Pair

extension ORSet {
    struct Pair: Hashable {
        let value: T
        let timestamp: Timestamp
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