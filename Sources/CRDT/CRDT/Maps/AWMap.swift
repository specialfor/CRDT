//
//  AWMap.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 20.04.2020.
//

public typealias AWMap<Key: Hashable, Value: Mergable> = ORMap<Key, Value> where Key: Codable, Value: Codable
