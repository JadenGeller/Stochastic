//
//  InteractionRecord.swift
//  Stochastic
//
//  Created by Jaden Geller on 2/20/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

/// A record that stores the reactants and products of an interaction.
public struct InteractionRecord<Molecule> {
    /// The reactants.
    public let reactants: [Molecule]
    
    private let _products: [Molecule]?
    /// The products.
    public var products: [Molecule] {
        return _products ?? reactants
    }
    
    internal init(reactants: [Molecule], products: [Molecule]?) {
        self.reactants = reactants
        self._products = products
    }
}

extension InteractionRecord {
    /// Returns `true` if no interaction occured.
    public var isStable: Bool {
        return _products == nil
    }
}

extension InteractionRecord where Molecule: Hashable {
    public var deltas: [Molecule : Int] {
        var result: [Molecule : Int] = [:]
        for molecule in reactants {
            result[molecule] = (result[molecule] ?? 0) - 1
        }
        for molecule in products {
            result[molecule] = (result[molecule] ?? 0) + 1
        }
        return result
    }
}
