//
//  CRDTSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 18.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public protocol CRDTSet: CRDT, Collection, ExpressibleByArrayLiteral where Element: Hashable, NestedValue == Set<Element>, Index == Set<Element>.Index, ArrayLiteralElement == Element {

    mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
    mutating func remove(_ member: Element) -> Element?
    mutating func update(with newMember: Element) -> Element?
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

    public func contains(_ member: Element) -> Bool {
        return value.contains(member)
    }

    public var isEmpty: Bool {
        return value.isEmpty
    }
}
