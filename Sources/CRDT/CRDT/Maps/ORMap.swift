//
//  ORMap.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 20.04.2020.
//

public struct ORMap<Key: Hashable, Value>: CRDT where Key: Codable, Value: Codable {
    public var value: [Key: Value] {
        return payload.value.reduce(into: [:]) { $0[$1.key] = $1.value }
    }
    var payload: ORSet<Pair> = []

    public subscript(key: Key) -> Value? {
        get {
            return value[key]
        }
        set {
            payload.remove(.init(key: key, value: nil))
            if let newValue = newValue {
                payload.insert(.init(key: key, value: newValue))
            }
        }
    }

    public mutating func merge(_ map: ORMap<Key, Value>) {
        payload.merge(map.payload)
    }

    public func hasConflict(with crdt: ORMap<Key, Value>) -> Bool {
        return false
    }
}

// MARK: - Pair

extension ORMap {
    struct Pair: Hashable, Codable {
        let key: Key
        let value: Value?

        func hash(into hasher: inout Hasher) {
            hasher.combine(key.hashValue)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.key == rhs.key
        }
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension ORMap: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        elements.forEach { payload.insert(.init(key: $0.0, value: $0.1)) }
    }
}

// MARK: - Comparable

extension ORMap: Comparable {
    public static func < (lhs: ORMap<Key, Value>, rhs: ORMap<Key, Value>) -> Bool {
        return lhs.payload < rhs.payload
    }

    public static func <= (lhs: ORMap<Key, Value>, rhs: ORMap<Key, Value>) -> Bool {
        return lhs.payload <= rhs.payload
    }

    public static func > (lhs: ORMap<Key, Value>, rhs: ORMap<Key, Value>) -> Bool {
        return lhs.payload > rhs.payload
    }

    public static func >= (lhs: ORMap<Key, Value>, rhs: ORMap<Key, Value>) -> Bool {
        return lhs.payload >= rhs.payload
    }
}

// MARK: - Equatable

extension ORMap: Equatable {
    public static func == (lhs: ORMap<Key, Value>, rhs: ORMap<Key, Value>) -> Bool {
        return lhs.payload == rhs.payload
    }
}

// MARK: - Collection

extension ORMap: Collection {
    public typealias Index = Dictionary<Key, Value>.Index
    public typealias Element = Dictionary<Key, Value>.Element

    public var startIndex: Index {
        return value.startIndex
    }

    public var endIndex: Index {
        return value.endIndex
    }

    public func index(after position: Index) -> Index {
        return value.index(after: position)
    }

    public subscript(position: Index) -> Element {
        return value[position]
    }
}
