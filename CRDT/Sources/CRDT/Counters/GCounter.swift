//
//  GCounter.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public struct GCounter: CRDT {
    var vector: [Int] = []

    #warning("Need to think...")
    public internal(set) var replicaNumber: Int = 0

    // MARK: - CRDT

    public var value: Int {
        return vector.reduce(0, +)
    }

    public mutating func increment() {
        precondition(replicaNumber < vector.count, "Replica number is out of range")
        vector[replicaNumber] += 1
    }

    public mutating func merge(_ counter: GCounter) {
        var rhsVector = counter.vector
        normalize(&vector, &rhsVector)

        vector = zip(vector, rhsVector).reduce(into: []) { (result, pair) in
            let maximumElement = max(pair.0, pair.1)
            result.append(maximumElement)
        }
    }

    func normalize(_ lhs: inout [Int], _ rhs: inout [Int]) {
        guard lhs.count != rhs.count else {
            return
        }

        if lhs.count < rhs.count {
            lhs.fillUp(by: 0, to: rhs.count)
        } else {
            rhs.fillUp(by: 0, to: lhs.count)
        }
    }

    public func hasConflict(with crdt: GCounter) -> Bool { 
        let isLessOrEqual = self <= crdt
        let isGreaterOrEqual = self >= crdt
        return !(isLessOrEqual || isGreaterOrEqual)
    }

    // MARK: - Comparable

    public static func < (lhs: GCounter, rhs: GCounter) -> Bool {
        return zip(lhs.vector, rhs.vector).allSatisfy { $0 <= $1 } && lhs != rhs
    }

    public static func <= (lhs: GCounter, rhs: GCounter) -> Bool {
        return zip(lhs.vector, rhs.vector).allSatisfy { $0 <= $1 }
    }

    public static func > (lhs: GCounter, rhs: GCounter) -> Bool {
        return zip(lhs.vector, rhs.vector).allSatisfy { $0 >= $1 } && lhs != rhs
    }

    public static func >= (lhs: GCounter, rhs: GCounter) -> Bool {
        return zip(lhs.vector, rhs.vector).allSatisfy { $0 >= $1 }
    }

    public static func == (lhs: GCounter, rhs: GCounter) -> Bool {
        return lhs.vector == rhs.vector
    }
}
