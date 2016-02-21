//
//  StochasticSystem.swift
//  Stochastic
//
//  Created by Jaden Geller on 2/19/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Erratic

/// System of molecules.
public struct StochasticSystem<Molecule> {
    internal var backing: RangeReplaceableLazyShuffleCollection<[Molecule]>
    
    /// Construct a system containing `molecules`.
    public init<S: SequenceType where S.Generator.Element == Molecule>(molecules: S) {
        backing = RangeReplaceableLazyShuffleCollection(unshuffled: Array(molecules))
    }
    
    /// Performs the `interaction`, returning the `InteractionRecord` on success and `nil` on failure.
    /// Note that failure implies that there were not enough molecules in the system to perform the interaction.
    public mutating func performInteraction(interaction: Interaction<Molecule>) -> InteractionRecord<Molecule>? {
        guard backing.count >= interaction.moleculeCount else { return nil }
        let range = 0..<interaction.moleculeCount

        // Obtain random sample
        backing.shuffleInPlace() // O(1) time complexity
        let reactants = Array(backing[range])
        
        // Perform interaction
        let record = interaction.run(reactants)
        backing.replaceRange(range, with: record.products)
        
        return record
    }
    
    public mutating func simulate(behavior: Behavior<Molecule>, stopping: Detector<Molecule>) {
        var stoppingCondition = stopping
        stoppingCondition.initialize(backing.base)
        while !stoppingCondition.satisfied {
            guard let record = performInteraction(behavior.interaction()) else { continue }
            stoppingCondition.account(record)
        }
    }
}
