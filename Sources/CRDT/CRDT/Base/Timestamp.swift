//
//  Timestamp.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 16.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public typealias Timestamp = Int

public extension Timestamp {
    var now: Timestamp {
        return self + 1
    }
}

extension Timestamp: Comparable {}
