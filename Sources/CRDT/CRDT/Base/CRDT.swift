//
//  CRDT.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public protocol CRDT: Mergable, Comparable, Hashable, Codable {
    associatedtype NestedValue

    var value: NestedValue { get }

    func hasConflict(with crdt: Self) -> Bool
}
