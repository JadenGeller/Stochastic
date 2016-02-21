//
//  Interaction.swift
//  Stochastic
//
//  Created by Jaden Geller on 2/20/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// A specification for an interaction that describes how many reacts are involved as well as
/// how to transform the reactants into products.
public struct Interaction<Molecule> {
    /// The number of reactants.
    public let moleculeCount: Int
    private let formula: [Molecule] -> [Molecule]?
    
    /// Construct an `Interaction` that will receive `moleculeCount` molecules and transform
    /// them via `formula`. Note that `formula` must return `nil` if the interaction is to
    /// be considered stable.
    public init(moleculeCount: Int, formula: [Molecule] -> [Molecule]?) {
        self.moleculeCount = moleculeCount
        self.formula = formula
    }
    
    /// Run the `Interaction` using `molecules` as the reactants, returning an `InteractionRecord`.
    public func run(molecules: [Molecule]) -> InteractionRecord<Molecule> {
        return InteractionRecord(reactants: molecules, products: formula(molecules))
    }
    
    /// Construct an interaction with 1 reactant.
    public init(formula: Molecule -> [Molecule]?) {
        self.init(moleculeCount: 1, formula: { formula($0[0]) })
    }
    
    /// Construct an interaction with 2 reactants.
    public init(formula: (Molecule, Molecule) -> [Molecule]?) {
        self.init(moleculeCount: 2, formula: { formula($0[0], $0[1]) })
    }
    
    /// Construct an interaction with 3 reactants.
    public init(formula: (Molecule, Molecule, Molecule) -> [Molecule]?) {
        self.init(moleculeCount: 3, formula: { formula($0[0], $0[1], $0[2]) })
    }
    
    /// Construct an interaction with 4 reactants.
    public init(formula: (Molecule, Molecule, Molecule, Molecule) -> [Molecule]?) {
        self.init(moleculeCount: 4, formula: { formula($0[0], $0[1], $0[2], $0[3]) })
    }
    
    /// Construct an interaction with 5 reactants.
    public init(formula: (Molecule, Molecule, Molecule, Molecule, Molecule) -> [Molecule]?) {
        self.init(moleculeCount: 5, formula: { formula($0[0], $0[1], $0[2], $0[3], $0[4]) })
    }
    
    /// Construct an interaction with 6 reactants.
    public init(formula: (Molecule, Molecule, Molecule, Molecule, Molecule, Molecule) -> [Molecule]?) {
        self.init(moleculeCount: 6, formula: { formula($0[0], $0[1], $0[2], $0[3], $0[4], $0[5]) })
    }
}
