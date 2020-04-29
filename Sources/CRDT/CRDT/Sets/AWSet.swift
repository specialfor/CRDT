//
//  AWSet.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

public typealias AWSet<T: Hashable> = ORSet<T> where T: Codable
