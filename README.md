# Stochastic

Stochastic is a discrete random interaction simulator. Let's start by checking out an example!
```swift
var system = StochasticSystem(molecules: [1, 2, 2, 4, 8, 8, 16])
let interaction = Interaction { a, b in
    guard a == b else { return nil }
    return [2 * a]
}

system.simulate(Behavior(interaction), stopping: .whenStable(streakLength: 50))
print(system.molecules.sort()) // -> [1, 8, 32]
```
