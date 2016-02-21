//
//  Behavior.swift
//  Stochastic
//
//  Created by Jaden Geller on 2/20/16.
//  Copyright © 2016 Jaden Geller. All rights reserved.
//

import Erratic

public struct Behavior<Molecule> {
    private var backing: () -> Interaction<Molecule>

    public init(_ interaction: Interaction<Molecule>) {
        self.backing = { interaction }
    }
    
    public init(_ interactions: [Interaction<Molecule>]) {
        precondition(interactions.count > 0, "Must supply at least one interaction.")
        var view = interactions.lazy.shuffle()
        self.backing = {
            view.shuffleInPlace()
            return view.first!
        }
    }
    
    public init(_ interactions: Interaction<Molecule>...) {
        self.init(interactions)
    }
    
    public init(build: () -> Interaction<Molecule>) {
        self.backing = build
    }
    
    public func interaction() -> Interaction<Molecule> {
        return backing()
    }
}
