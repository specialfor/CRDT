//
//  Mergable.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 03.05.2020.
//

public protocol Mergable {
    mutating func merge(_ object: Self)
}

public extension Mergable {
    func merging(_ object: Self) -> Self {
        var temp = self
        temp.merge(object)
        return temp
    }
}

public protocol PrimitiveMergable: Mergable {}
public extension PrimitiveMergable {
    mutating func merge(_ object: Self) {}
}

extension Int: PrimitiveMergable {}
extension Float: PrimitiveMergable {}
extension Double: PrimitiveMergable {}
extension Bool: PrimitiveMergable {}
extension String: PrimitiveMergable {}

extension Array: Mergable where Element: Mergable {
    public mutating func merge(_ object: Array<Element>) {}
}

extension Array: PrimitiveMergable where Element: PrimitiveMergable {}


extension Set: Mergable where Element: Mergable {
    public mutating func merge(_ object: Set<Element>) {}
}

extension Set: PrimitiveMergable where Element: PrimitiveMergable {}


extension Dictionary: Mergable where Value: Mergable {
    public mutating func merge(_ object: Dictionary<Key, Value>) {}
}

extension Dictionary: PrimitiveMergable where Value: PrimitiveMergable {}
