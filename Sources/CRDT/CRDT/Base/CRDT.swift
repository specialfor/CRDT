//
//  CRDT.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public protocol CRDT: Comparable {
    associatedtype Value

    var replicaNumber: Int { get }
    var value: Value { get }

    mutating func merge(_ crdt: Self)

    func hasConflict(with crdt: Self) -> Bool
}

extension CRDT {
    func merging(_ crdt: Self) -> Self {
        var temp = self
        temp.merge(crdt)
        return temp
    }
}
