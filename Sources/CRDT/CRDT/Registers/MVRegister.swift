//
//  MVRegister.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 17.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

public struct MVRegister<T: Hashable>: CRDT {
    #warning("Need to change `value` type to Set<T>.")
    #warning("Old `value` property should be renamed to `payload`.")
    public internal(set) var value: Set<Pair>

    public init(value: T) {
        self.value = [value].toMVRegisterSet(vector: .initial)
    }

    init(value: Set<Pair>) {
        self.value = value
    }

    public mutating func assign(_ value: T) {
        assign([value])
    }

    public mutating func assign(_ value: Set<T>) {
        let vector = incrementedVector()
        self.value = value.toMVRegisterSet(vector: vector)
    }

    func incrementedVector() -> VectorStamp {
        var newVector: VectorStamp = value
            .map { $0.vector }
            .reduce(into: [:]) { result, vector in
                result.merge(vector)
        }

        let value = newVector[Device.id] ?? 0
        newVector[Device.id] = value + 1

        return newVector
    }

    public mutating func merge(_ register: MVRegister<T>) {
        let lhsDominated = dominatedSubset(using: register)
        let rhsDominated = register.dominatedSubset(using: self)

        value = lhsDominated.union(rhsDominated)
    }

    func dominatedSubset(using register: MVRegister<T>) -> Set<Pair> {
        var set: Set<Pair> = []

        for i in value {
            let iVector = i.vector
            var shouldAdd = true

            for j in register.value {
                let jVector = j.vector
                let isDominated = iVector.hasConflict(with: jVector)
                    || jVector <= iVector
                shouldAdd = shouldAdd && isDominated
            }

            if shouldAdd {
                set.insert(i)
            }
        }

        return set
    }

    public func hasConflict(with crdt: MVRegister<T>) -> Bool {
        return !(self <= crdt) && !(self >= crdt)
    }
}

// MARK: - Comparable

extension MVRegister: Comparable {
    public static func < (lhs: MVRegister<T>, rhs: MVRegister<T>) -> Bool {
        return strictCompare(lhs, rhs, comparator: <=)
    }

    static func strictCompare(_ lhs: MVRegister<T>,
                        _ rhs: MVRegister<T>,
                        comparator: (VectorStamp, VectorStamp) -> Bool) -> Bool {
        let lhsVectors = lhs.value.map { $0.vector }
        let rhsVectors = rhs.value.map { $0.vector }

        var result = true
        var allEqual = true

        for i in lhsVectors {
            for j in rhsVectors {
                result = result && comparator(i, j)
                if i != j {
                    allEqual = false
                }
            }
        }

        return result && !allEqual
    }

    public static func <= (lhs: MVRegister<T>, rhs: MVRegister<T>) -> Bool {
        return compare(lhs, rhs, comparator: <=)
    }

    static func compare(_ lhs: MVRegister<T>,
                        _ rhs: MVRegister<T>,
                        comparator: (VectorStamp, VectorStamp) -> Bool) -> Bool {
        let lhsVectors = lhs.value.map { $0.vector }
        let rhsVectors = rhs.value.map { $0.vector }

        var result = true

        for i in lhsVectors {
            for j in rhsVectors {
                result = result && comparator(i, j)
            }
        }

        return result
    }

    public static func >= (lhs: MVRegister<T>, rhs: MVRegister<T>) -> Bool {
        return compare(lhs, rhs, comparator: >=)
    }

    public static func > (lhs: MVRegister<T>, rhs: MVRegister<T>) -> Bool {
        return strictCompare(lhs, rhs, comparator: >=)
    }
}

// MARK: - Equatable

extension MVRegister: Equatable {
    public static func == (lhs: MVRegister<T>, rhs: MVRegister<T>) -> Bool {
        return lhs.value == rhs.value
    }
}

// MARK: - Pair

extension MVRegister {
    public struct Pair: Hashable {
        public internal(set) var value: T
        public internal(set) var vector: VectorStamp

        public func hash(into hasher: inout Hasher) {
            hasher.combine(value)
        }

        public static func == (lhs: Pair, rhs: Pair) -> Bool {
            return lhs.value == rhs.value
        }
    }
}

extension MVRegister.Pair: Codable where T: Codable {}

// MARK: - ExpressibleByArrayLiteral

extension MVRegister: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: T...) {
        self.value = elements.toMVRegisterSet(vector: .initial)
    }
}

// MARK: - Array

extension Collection where Element: Hashable {
    func toMVRegisterSet(vector: VectorStamp) -> MVRegister<Element>.NestedValue {
        return Set(map { .init(value: $0, vector: vector) })
    }
}

// MARK: - Codable

extension MVRegister: Codable where T: Codable {}
