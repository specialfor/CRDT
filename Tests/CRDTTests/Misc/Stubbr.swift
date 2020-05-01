//
//  Stubbr.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 16.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

final class Stubbr {
    typealias Pair = (value: Any, setter: (Any) -> Void)
    var pairs: [Pair] = []

    func stub<T>(getter: () -> T,
                 setter: @escaping (T) -> Void,
                 stubbed: T) {
        let pair = Pair(
            value: getter(),
            setter: { value in
                setter(value as! T)
            })
        pairs.append(pair)
        setter(stubbed)
    }

    func restore() {
        pairs.forEach { $0.setter($0.value) }
        pairs = []
    }

    deinit {
        restore()
    }
}
