//
//  UniqueTag.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 01.05.2020.
//

import Foundation

public typealias UniqueTag = String

public extension UniqueTag {
    static var unique: UniqueTag {
        return "\(Device.id)_\(UUID().uuidString)"
    }
}
