//
//  GCounter.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public struct GCounter: CRDT {
    var vector = VersionVector()

    #warning("Can be removed after migration to VectorStamp")
    public internal(set) var replicaNumber: Int = 0

    public var value: Int {
        return vector.reduce(0, +)
    }

    public mutating func increment() {
        precondition(replicaNumber < vector.count, "Replica number is out of range")
        vector[replicaNumber] += 1
    }

    public mutating func merge(_ counter: GCounter) {
        vector.merge(counter.vector)
    }

    public func hasConflict(with counter: GCounter) -> Bool {
        return vector.hasConflict(with: counter.vector)
    }
}

// MARK: - Comparable

extension GCounter: Comparable {
    public static func < (lhs: GCounter, rhs: GCounter) -> Bool {
        return lhs.vector < rhs.vector
    }

    public static func <= (lhs: GCounter, rhs: GCounter) -> Bool {
        return lhs.vector <= rhs.vector
    }

    public static func > (lhs: GCounter, rhs: GCounter) -> Bool {
        return lhs.vector > rhs.vector
    }

    public static func >= (lhs: GCounter, rhs: GCounter) -> Bool {
        return lhs.vector >= rhs.vector
    }
}

// MARK: - Equatable

extension GCounter: Equatable {
    public static func == (lhs: GCounter, rhs: GCounter) -> Bool {
        return lhs.vector == rhs.vector
    }
}
