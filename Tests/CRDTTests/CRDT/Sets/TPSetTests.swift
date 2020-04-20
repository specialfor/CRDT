//
//  TPSetTests.swift
//  CRDTTests
//
//  Created by Volodymyr Hryhoriev on 19.04.2020.
//

import XCTest

@testable import CRDT

final class TPSetTests: TestCase {
    
    // MARK: - Init
    
    func testInit_default_allSetsAreEmpty() {
        let set = TPSet<Int>()
        
        XCTAssertEqual(set.value, [])
        XCTAssertEqual(set.addedValues, [])
        XCTAssertEqual(set.removedValues, [])
    }
    
    func testInit_expressibleByArrayLiteral_valueAndAddedValuesEqualsToArrayLiteral() {
        let set: TPSet<Int> = [1, 2, 3]
        
        XCTAssertEqual(set.value, [1, 2, 3])
        XCTAssertEqual(set.addedValues, [1, 2, 3])
        XCTAssertEqual(set.removedValues, [])
    }
    
    // MARK: - Insert
    
    func testInsert_onEmpty_inserted() {
        var set: TPSet<Int> = []
        
        set.insert(2)
        set.insert(2)
        
        XCTAssertTrue(set.contains(2))
        XCTAssertEqual(set.value, [2])
        XCTAssertEqual(set.addedValues, [2])
        XCTAssertEqual(set.removedValues, [])
    }
    
    func testInsert_onNonEmpty_inserted() {
        var set: TPSet<Int> = [1, 2]
        
        set.insert(3)
        set.insert(2)
        set.insert(3)
        
        XCTAssertTrue(set.contains(3))
        XCTAssertEqual(set.value, [1, 2, 3])
        XCTAssertEqual(set.addedValues, [1, 2, 3])
        XCTAssertEqual(set.removedValues, [])
    }
    
    // MARK: - Remove
    
    func testRemove_onEmpty() {
        var set: TPSet<Int> = []
        
        set.remove(2)
        set.remove(2)
        
        XCTAssertFalse(set.contains(2))
        XCTAssertEqual(set.value, [])
        XCTAssertEqual(set.addedValues, [])
        XCTAssertEqual(set.removedValues, [])
    }
    
    func testRemove_onNonEmpty() {
        var set: TPSet<Int> = [1, 2]
        
        set.remove(2)
        set.remove(3)
        
        XCTAssertFalse(set.contains(2))
        XCTAssertFalse(set.contains(3))
        XCTAssertEqual(set.value, [1])
        XCTAssertEqual(set.addedValues, [1, 2])
        XCTAssertEqual(set.removedValues, [2])
    }
    
    // MARK: - Merge
    
    func testMerge_onEmpty_equalsArgument() {
        let set: TPSet<Int> = []
        
        var set2: TPSet<Int> = [1, 2]
        set2.remove(2)
        
        let result = set.merging(set2)
        
        XCTAssertEqual(result.value, [1])
        XCTAssertEqual(result.addedValues, [1, 2])
        XCTAssertEqual(result.removedValues, [2])
    }
    
    func testMerge_onNonEmpty_equalsUnionOfSets() {
        var set: TPSet<Int> = [1, 2, 3]
        set.remove(1)
        
        var set2: TPSet<Int> = [1, 2, 4]
        set2.remove(2)
        
        let result = set.merging(set2)
        
        XCTAssertEqual(result.value, [3, 4])
        XCTAssertEqual(result.addedValues, [1, 2, 3, 4])
        XCTAssertEqual(result.removedValues, [1, 2])
    }
    
    // MARK: - HasConflict
    
    func testHasConflict() {
        let set1: TPSet<Int> = []
        
        var set2: TPSet<Int> = [1, 2]
        set2.remove(2)
        
        var set3: TPSet<Int> = [1, 2, 3]
        set3.remove(1)
        
        var set4: TPSet<Int> = [1, 2, 4]
        set4.remove(2)
        
        XCTAssertFalse(set1.hasConflict(with: set2))
        XCTAssertFalse(set2.hasConflict(with: set3))
        XCTAssertFalse(set3.hasConflict(with: set4))
    }
    
    // MARK: - Comparable
    
    func testCompare() {
        let set1: TPSet<Int> = []
        
        var set2: TPSet<Int> = [1, 2]
        set2.remove(2)
        
        var set3: TPSet<Int> = [1, 2, 3]
        set3.remove(1)
        
        var set4: TPSet<Int> = [1, 2, 4]
        set4.remove(2)
        
        var set5: TPSet<Int> = [5, 6]
        set5.remove(6)
        
        // <
        XCTAssertLessThan(set1, set2)
        XCTAssertLessThan(set2, set3)
        XCTAssertLessThan(set2, set4)
        XCTAssertFalse(set3 < set3)
        XCTAssertFalse(set3 < set5)
        XCTAssertFalse(set3 < set4)
        
        // <=
        XCTAssertLessThanOrEqual(set1, set2)
        XCTAssertLessThanOrEqual(set2, set3)
        XCTAssertLessThanOrEqual(set2, set4)
        XCTAssertLessThanOrEqual(set3, set3)
        XCTAssertFalse(set3 <= set5)
        XCTAssertFalse(set3 <= set4)
        
        // >
        XCTAssertGreaterThan(set2, set1)
        XCTAssertGreaterThan(set3, set2)
        XCTAssertGreaterThan(set4, set2)
        XCTAssertFalse(set3 > set3)
        XCTAssertFalse(set5 > set3)
        XCTAssertFalse(set4 > set3)
        
        // >=
        XCTAssertGreaterThanOrEqual(set2, set1)
        XCTAssertGreaterThanOrEqual(set3, set2)
        XCTAssertGreaterThanOrEqual(set4, set2)
        XCTAssertGreaterThanOrEqual(set3, set3)
        XCTAssertFalse(set5 >= set3)
        XCTAssertFalse(set4 >= set3)
    }
    
    // MARK: - Equatable
    
    func testEqual() {
        let set1: TPSet<Int> = []
        let set2: TPSet<Int> = [1, 2]
        
        var set3: TPSet<Int> = [1, 2, 3]
        set3.remove(3)
        
        var set4: TPSet<Int> = [1, 2, 3]
        set4.remove(3)
        
        var set5: TPSet<Int> = [1, 2, 3]
        set5.remove(3)
        set5.remove(2)
        
        XCTAssertEqual(set1, [])
        XCTAssertEqual(set2, [1, 2])
        XCTAssertEqual(set3, set4)
        
        XCTAssertNotEqual(set1, set2)
        XCTAssertNotEqual(set2, set3)
        XCTAssertNotEqual(set2, set4)
        XCTAssertNotEqual(set2, set5)
        XCTAssertNotEqual(set3, set5)
    }
}
