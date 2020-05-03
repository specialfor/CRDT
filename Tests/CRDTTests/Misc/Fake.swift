//
//  Fake.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 02.05.2020.
//

@testable import CRDT

enum Fake {
    static let mghStruct = MGHStruct(id: 1, payload: [1, 2])
    static let mghStructWithSameId = MGHStruct(id: 1, payload: [3, 4])
    static let mghStructWithDifferentId = MGHStruct(id: 2, payload: [3, 4])

    static let mohStruct = MOHStruct(id: 1, payload: [1, 2])
    static let mohStructWithSameId = MOHStruct(id: 1, payload: [3, 4])
    static let mohStructWithDifferentId = MOHStruct(id: 2, payload: [3, 4])
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
