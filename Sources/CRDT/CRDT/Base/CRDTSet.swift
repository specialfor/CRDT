//
//  CRDTSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 18.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public protocol CRDTSet: CRDT, Collection, SetAlgebra where Element: Hashable, Value == Set<Element>, Index == Set<Element>.Index, ArrayLiteralElement == Element {
    var value: Value { get set }
}

// MARK: - ExpressibleByArrayLiteral

extension CRDTSet {
    public init(arrayLiteral elements: Element...) {
        self.init()
        value = Set(elements)
    }
}

// MARK: - SetAlgebra

extension CRDTSet {
    public func union(_ other: Self) -> Self {
        var temp = self
        temp.formUnion(other)
        return temp
    }

    public func intersection(_ other: Self) -> Self {
        var temp = self
        temp.formIntersection(other)
        return temp
    }

    public func symmetricDifference(_ other: Self) -> Self {
        var temp = self
        temp.formSymmetricDifference(other)
        return temp
    }

    public mutating func insert(_ newMember: Self.Element) -> (inserted: Bool, memberAfterInsert: Self.Element) {
        return value.insert(newMember)
    }

    public mutating func remove(_ member: Self.Element) -> Self.Element? {
        return value.remove(member)
    }

    public mutating func update(with newMember: Self.Element) -> Self.Element? {
        return value.update(with: newMember)
    }

    public mutating func formUnion(_ other: Self) {
        value = value.union(other.value)
    }

    public mutating func formIntersection(_ other: Self) {
        value = value.intersection(other.value)
    }

    public mutating func formSymmetricDifference(_ other: Self) {
        value = value.symmetricDifference(other.value)
    }

    public func contains(_ member: Element) -> Bool {
        return value.contains(member)
    }
}

// MARK: - Collection

extension CRDTSet {
    public var startIndex: Self.Index {
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

// MARK: - Common

extension CRDTSet {
    public var isEmpty: Bool {
        return value.isEmpty
    }
}
