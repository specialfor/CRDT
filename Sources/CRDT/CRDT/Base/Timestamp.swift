//
//  Timestamp.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 16.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public typealias Timestamp = Int

public extension Timestamp {
    internal static var current: Timestamp = .initial

    static var initial: Timestamp = 0

    static var now: Timestamp {
        current = current.next
        return current
    }

    var next: Timestamp {
        return self + 1
    }
}

extension Timestamp: Comparable, Codable {}
