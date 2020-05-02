//
//  CRDT.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public protocol Mergable {
    mutating func merge(_ object: Self)
}

public extension Mergable {
    func merging(_ object: Self) -> Self {
        var temp = self
        temp.merge(object)
        return temp
    }
}

public protocol CRDT: Mergable, Comparable, Hashable, Codable {
    associatedtype NestedValue

    var value: NestedValue { get }

    func hasConflict(with crdt: Self) -> Bool
}
