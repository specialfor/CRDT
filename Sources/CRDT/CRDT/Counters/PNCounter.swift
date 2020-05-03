//
//  PNCounter.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public struct PNCounter: CRDT {
    var incrementCounter: GCounter = GCounter()
    var decrementCounter: GCounter = GCounter()

    #warning("Can be removed after migration to VectorStamp")
    public internal(set) var replicaNumber: Int = 0 {
        didSet {
            incrementCounter.replicaNumber = replicaNumber
            decrementCounter.replicaNumber = replicaNumber
        }
    }

    // MARK: - CRDT

    public var value: Int {
        return incrementCounter.value - decrementCounter.value
    }

    public mutating func increment() {
        incrementCounter.increment()
    }

    public mutating func decrement() {
        decrementCounter.increment()
    }

    public mutating func merge(_ counter: PNCounter) {
        incrementCounter.merge(counter.incrementCounter)
        decrementCounter.merge(counter.decrementCounter)
    }

    public func hasConflict(with crdt: PNCounter) -> Bool {
        return incrementCounter.hasConflict(with: crdt.incrementCounter)
            || decrementCounter.hasConflict(with: crdt.decrementCounter)
    }

    // MARK: - Comparable

    public static func < (lhs: PNCounter, rhs: PNCounter) -> Bool {
        return lhs.incrementCounter < rhs.incrementCounter
            && lhs.decrementCounter < rhs.decrementCounter
    }

    public static func <= (lhs: PNCounter, rhs: PNCounter) -> Bool {
        return lhs.incrementCounter <= rhs.incrementCounter
            && lhs.decrementCounter <= rhs.decrementCounter
    }

    public static func > (lhs: PNCounter, rhs: PNCounter) -> Bool {
        return lhs.incrementCounter > rhs.incrementCounter
            && lhs.decrementCounter > rhs.decrementCounter
    }

    public static func >= (lhs: PNCounter, rhs: PNCounter) -> Bool {
        return lhs.incrementCounter >= rhs.incrementCounter
            && lhs.decrementCounter >= rhs.decrementCounter
    }

    public static func == (lhs: PNCounter, rhs: PNCounter) -> Bool {
        return lhs.incrementCounter == rhs.incrementCounter
            && lhs.decrementCounter == rhs.decrementCounter
    }
}

// MARK: - Codable

extension PNCounter: Codable {}
