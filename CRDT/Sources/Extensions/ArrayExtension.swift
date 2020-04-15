//
//  ArrayExtension.swift
//  CRDT
//
//  Created by Volodymyr Hryhoriev on 15.04.2020.
//  Copyright © 2020 Volodymyr Hryhoriev. All rights reserved.
//

extension Array {
    mutating func fillUp(by element: Element, to count: Int) {
        guard count > self.count else {
            return
        }

        reserveCapacity(count)

        let countDifference = count - self.count
        let elements: [Element] = .init(repeating: element, count: countDifference)

        append(contentsOf: elements)
    }
}
