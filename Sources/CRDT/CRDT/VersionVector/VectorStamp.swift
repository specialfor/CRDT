//
//  VectorStamp.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 01.05.2020.
//

public struct VectorStamp {
    static let initial: VectorStamp = [Device.id: 0]

    public typealias Elements = [Device.ID: Int]
    public private(set) var elements = Elements()

    init(_ elements: Elements) {
        self.elements = elements
    }

    public mutating func merge(_ vector: VectorStamp) {
        vector.elements.forEach { key, value in
            if let currentValue = elements[key] {
                elements[key] = Swift.max(currentValue, value)
            } else {
                elements[key] = value
            }
        }
    }

    public func merging(_ vector: VectorStamp) -> VectorStamp {
        var lhs = self
        lhs.merge(vector)
        return lhs
    }

    public func hasConflict(with vector: VectorStamp) -> Bool {
        let isLessOrEqual = self <= vector
        let isGreaterOrEqual = self >= vector
        return !(isLessOrEqual || isGreaterOrEqual)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension VectorStamp: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Device.ID, Int)...) {
        elements.forEach { key, value in
            self.elements[key] = value
        }
    }
}

// MARK: - Comparable

extension VectorStamp: Comparable {
    public static func < (lhs: VectorStamp, rhs: VectorStamp) -> Bool {
        return lhs <= rhs && lhs != rhs
    }

    public static func <= (lhs: VectorStamp, rhs: VectorStamp) -> Bool {
        let lhsKeys = Set(lhs.elements.keys)
        let rhsKeys = Set(rhs.elements.keys)

        guard lhsKeys.isSubset(of: rhsKeys) else {
            return false
        }

        return lhs.elements.allSatisfy { key, value in
            return value <= rhs.elements[key]!
        }
    }

    public static func > (lhs: VectorStamp, rhs: VectorStamp) -> Bool {
        return lhs >= rhs && lhs != rhs
    }

    public static func >= (lhs: VectorStamp, rhs: VectorStamp) -> Bool {
        let lhsKeys = Set(lhs.elements.keys)
        let rhsKeys = Set(rhs.elements.keys)

        guard lhsKeys.isSuperset(of: rhsKeys) else {
            return false
        }

        return rhs.elements.allSatisfy { key, value in
            return value <= lhs.elements[key]!
        }
    }
}

// MARK: - Equatable

extension VectorStamp: Hashable {
    public static func == (lhs: VectorStamp, rhs: VectorStamp) -> Bool {
        return lhs.elements == rhs.elements
    }
}

// MARK: - Collection

extension VectorStamp: Collection {
    public var startIndex: Elements.Index {
        return elements.startIndex
    }

    public var endIndex: Elements.Index {
        return elements.endIndex
    }

    public subscript(index: Elements.Index) -> (key: Device.ID, value: Int) {
        get {
            return elements[index]
        }
    }

    public subscript(key: Device.ID) -> Int? {
        get {
            return elements[key]
        }
        set {
            elements[key] = newValue
        }
    }

    public func index(after i: Elements.Index) -> Elements.Index {
        return elements.index(after: i)
    }
}

// MARK: - Codable

extension VectorStamp: Codable {}
