//
//  VersionVector.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 16.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public struct VersionVector {
    static let initial: VersionVector = [0]

    public private(set) var elements: [Int] = []

    init(_ elements: [Int]) {
        self.elements = elements
    }

    public mutating func merge(_ vector: VersionVector) {
        var rhsElements = vector.elements
        VersionVector.normalize(&elements, &rhsElements)

        elements = zip(elements, rhsElements).reduce(into: []) { (result, pair) in
            let maximumElement = Swift.max(pair.0, pair.1)
            result.append(maximumElement)
        }
    }

    public func merging(_ vector: VersionVector) -> VersionVector {
        var lhs = self
        lhs.merge(vector)
        return lhs
    }

    static func normalize(_ lhs: inout [Int], _ rhs: inout [Int]) {
        guard lhs.count != rhs.count else {
            return
        }

        if lhs.count < rhs.count {
            lhs.fillUp(by: 0, to: rhs.count)
        } else {
            rhs.fillUp(by: 0, to: lhs.count)
        }
    }

    public func hasConflict(with vector: VersionVector) -> Bool {
        let isLessOrEqual = self <= vector
        let isGreaterOrEqual = self >= vector
        return !(isLessOrEqual || isGreaterOrEqual)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension VersionVector: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Int...) {
        self.init(elements)
    }
}

// MARK: - Collection

extension VersionVector: Collection {
    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public subscript(index: Int) -> Int {
        get {
            return elements[index]
        }
        set(newValue) {
            elements[index] = newValue
        }
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }
}

// MARK: - BidirecctionCollection

extension VersionVector: BidirectionalCollection {
    public func index(before i: Int) -> Int {
        return i - 1
    }
}

// MARK: - Comparable

extension VersionVector: Comparable {
    public static func < (lhs: VersionVector, rhs: VersionVector) -> Bool {
        return zip(lhs.elements, rhs.elements).allSatisfy { $0 <= $1 } && lhs != rhs
    }

    public static func <= (lhs: VersionVector, rhs: VersionVector) -> Bool {
        return zip(lhs.elements, rhs.elements).allSatisfy { $0 <= $1 }
    }

    public static func > (lhs: VersionVector, rhs: VersionVector) -> Bool {
        return zip(lhs.elements, rhs.elements).allSatisfy { $0 >= $1 } && lhs != rhs
    }

    public static func >= (lhs: VersionVector, rhs: VersionVector) -> Bool {
        return zip(lhs.elements, rhs.elements).allSatisfy { $0 >= $1 }
    }
}

// MARK: - Equatable

extension VersionVector: Hashable {
    public static func == (lhs: VersionVector, rhs: VersionVector) -> Bool {
        return lhs.elements == rhs.elements
    }
}

// MARK: - Codable

extension VersionVector: Codable {}
