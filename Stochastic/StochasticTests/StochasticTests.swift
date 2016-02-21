//
//  StochasticTests.swift
//  StochasticTests
//
//  Created by Jaden Geller on 2/19/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import XCTest
@testable import Stochastic
import Erratic

class StochasticTests: XCTestCase {
    func test2048() {
        var system = StochasticSystem(molecules: [1, 2, 2, 4, 8, 8, 16])
        system.simulate(Behavior(Interaction { a, b in
            guard a == b else { return nil }
            return [2 * a]
        }), stopping: .whenStable(streakLength: 50))
        XCTAssertEqual([1, 8, 32], system.backing.base.sort())
    }
    
    func testRepeat() {
        var system = StochasticSystem(molecules: Repeat(count: 50, repeatedValue: 1))
        system.simulate(Behavior(Interaction { a, b in
            guard a == b else { return nil }
            return [a]
            }), stopping: .after(count: 10))
        XCTAssertEqual(40, system.backing.base.count)
    }
    
    func testSteadyState() {
        var system = StochasticSystem(molecules: Array(Repeat(count: 100, repeatedValue: 1)) + [0])
        system.simulate(Behavior(Interaction { a, b in
            guard a == b else { return nil }
            return [a, 1 - a]
        }), stopping: .whenStable(streakLength: 70, absoluteTolerance: 2))
        let sum = system.backing.reduce(0, combine: +)
        XCTAssert(sum >= 45 && sum <= 55)
    }
}

