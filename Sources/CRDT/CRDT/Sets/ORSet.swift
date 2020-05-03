//
//  ORSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public struct ORSet<T: Hashable>: CRDTRemovableSet, CRDTUpdatableSet where T: Mergable {
    #warning("Is it possible to omit line below?")
    public typealias Element = T

    public var value: Set<T>

    private var valueArray: [T] {
        return payload.map { $0.value }
    }

    var payload: TPSet<Pair>

    public init() {
        payload = []
        value = []
    }

    public init(arrayLiteral elements: T...) {
        self.init(elements)
    }

    public init<U: Sequence>(_ sequence: U) where U.Element == T {
        self.init()
        sequence.forEach { insert($0) }
        value = Set(valueArray)
    }

    public mutating func assign(_ newValue: Set<T>) {
        guard newValue != value else {
            return
        }

        let newValueDiff = newValue.subtracting(value)
        let valueDiff = value.subtracting(newValue)

        valueDiff.forEach { remove($0) }
        newValueDiff.forEach { insert($0) }
        value = Set(valueArray)
    }

    @discardableResult
    public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
        let isContained = contains(newMember)
        _ = payload.insert(.init(value: newMember, tag: .unique))
        value.insert(newMember)
        return (!isContained, newMember)
    }

    @discardableResult
    public mutating func remove(_ member: T) -> T? {
        let pairs = payload.filter { $0.value == member }
        pairs.forEach { _ = payload.remove($0) }

        let isRemoved = !pairs.isEmpty
        if isRemoved {
            value.remove(member)
        }

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

        value = Set(valueArray)
    }

    public func hasConflict(with crdt: ORSet<T>) -> Bool {
        return false
    }
}

// MARK: - Pair

extension ORSet {
    struct Pair: Hashable {
        let value: T
        let tag: UniqueTag
    }
}

extension ORSet.Pair: Codable where T: Codable {}

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

// MARK: - Codable

extension ORSet: Codable where T: Codable {
    private enum CodingKeys: String, CodingKey {
        case payload
    }

    public init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        payload = try container.decode(TPSet<Pair>.self, forKey: .payload)
        value = Set(valueArray)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(payload, forKey: .payload)
    }
}
