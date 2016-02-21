//
//  Detector.swift
//  Stochastic
//
//  Created by Jaden Geller on 2/20/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

private enum DetectorPhase<Molecule> {
    case Setup([Molecule] -> InteractionRecord<Molecule> -> Bool)
    case Detect(InteractionRecord<Molecule> -> Bool)
}

public struct Detector<Molecule> {
    private var phase: DetectorPhase<Molecule>
    private(set) public var satisfied: Bool = false

    public mutating func initialize(initial: [Molecule]) {
        guard case .Setup(let setup) = phase else {
            fatalError("Detector may only be initialized once.")
        }
        phase = .Detect(setup(initial))
    }
    
    public mutating func account(record: InteractionRecord<Molecule>) {
        guard case .Detect(let detect) = phase else {
            fatalError("Detector requires initialization.")
        }
        satisfied = detect(record)
    }
    
    public init(detector: [Molecule] -> InteractionRecord<Molecule> -> Bool) {
        self.phase = .Setup(detector)
    }
}

extension Detector {
    public static func immediately() -> Detector {
        return Detector { _ in { _ in true } }
    }
    
    public static func never() -> Detector {
        return Detector { _ in { _ in false } }
    }
    
    public static func after(count targetCount: Int) -> Detector {
        return Detector { _ in
            var count = 0
            return { _ in
                count += 1
                return count >= targetCount
            }
        }
    }
    
    public static func whenStable(streakLength streakLength: Int) -> Detector {
        return Detector { _ in
            var count = 0
            return { record in
                if record.isStable {
                    count++
                } else {
                    count = 0
                }
                return count >= streakLength
            }
        }
    }
}

extension Detector where Molecule: Hashable {
    private init(streakLength: Int, detector: (rollingDelta: [Molecule : Int], moleculeCount: Int) -> Bool) {
        self.init { molecules in
            var moleculeCount = molecules.count
            var rollingDelta: [Molecule : Int] = [:]
            var deltaQueue: [[Molecule : Int]] = []
            return { record in
                let newDelta = record.deltas
                    
                // Add new delta to rolling window and update counts
                deltaQueue.append(newDelta)
                for (key, value) in newDelta {
                    rollingDelta[key] = (rollingDelta[key] ?? 0) + value
                    moleculeCount += value
                }
                
                // Wait until we've collected enough data
                guard deltaQueue.count == streakLength else {
                    assert(deltaQueue.count < streakLength)
                    return false
                }

                // Remove old delta from rolling window
                defer {
                    let oldDelta = deltaQueue.removeFirst()
                    for (key, value) in oldDelta {
                        rollingDelta[key] = rollingDelta[key]! - value // can't be nil since we're undoing
                    }
                }
                
                return detector(rollingDelta: rollingDelta, moleculeCount: moleculeCount)
            }
        }
    }
    
    public static func whenStable(streakLength streakLength: Int, absoluteTolerance: Int) -> Detector {
        return Detector(streakLength: streakLength) { rollingDelta, moleculeCount in
            let deviation = rollingDelta.values.map(abs).reduce(0, combine: +)
            return deviation <= absoluteTolerance
        }
    }
    
    public static func whenStable(streakLength streakLength: Int, percentTolerance: Float) -> Detector {
        return Detector(streakLength: streakLength) { rollingDelta, moleculeCount in
            let deviation = rollingDelta.values.map(abs).reduce(0, combine: +)
            return Float(deviation) / Float(moleculeCount) <= percentTolerance
        }
    }
}
