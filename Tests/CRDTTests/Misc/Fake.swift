//
//  Fake.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 02.05.2020.
//

@testable import CRDT

enum Fake {
    static let ghStruct = GHStruct(id: 1, payload: [1, 2])
    static let ghStructWithSameId = GHStruct(id: 1, payload: [3, 4])
    static let ghStructWithDifferentId = GHStruct(id: 2, payload: [3, 4])

    static let ohStruct = OHStruct(id: 1, payload: [1, 2])
    static let ohStructWithSameId = OHStruct(id: 1, payload: [3, 4])
    static let ohStructWithDifferentId = OHStruct(id: 2, payload: [3, 4])

    static let mghStruct = MGHStruct(id: 1, payload: [1, 2])
    static let mghStructWithSameId = MGHStruct(id: 1, payload: [3, 4])
    static let mghStructWithDifferentId = MGHStruct(id: 2, payload: [3, 4])

    static let mohStruct = MOHStruct(id: 1, payload: [1, 2])
    static let mohStructWithSameId = MOHStruct(id: 1, payload: [3, 4])
    static let mohStructWithDifferentId = MOHStruct(id: 2, payload: [3, 4])
}

struct GHStruct: Hashable, Codable {
    var id: Int
    var payload: [Int]
}

struct OHStruct: Hashable, Codable {
    var id: Int
    var payload: [Int]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: OHStruct, rhs: OHStruct) -> Bool {
        return lhs.id == rhs.id
    }
}

struct MGHStruct: Hashable, Mergable, Codable {
    var id: Int
    var payload: AWSet<Int>

    mutating func merge(_ object: MGHStruct) {
        guard id == object.id else {
            return
        }

        payload.merge(object.payload)
    }
}

struct MOHStruct: Hashable, Mergable, Codable {
    var id: Int
    var payload: AWSet<Int>

    mutating func merge(_ object: MOHStruct) {
        guard id == object.id else {
            return
        }

        payload.merge(object.payload)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MOHStruct, rhs: MOHStruct) -> Bool {
        return lhs.id == rhs.id
    }
}
