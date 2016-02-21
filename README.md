# Stochastic

Stochastic is a discrete random interaction simulator. Let's start by checking out an example!
```swift
var system = StochasticSystem(molecules: [1, 2, 2, 4, 8, 8, 16])

// x + x -> 2 * x
let mergeInteraction = Interaction { a, b in
    guard a == b else { return nil }
    return [2 * a]
}

system.simulate(Behavior(mergeInteraction), stopping: .whenStable(streakLength: 50))
print(system.molecules.sort()) // -> [1, 8, 32]
```
This interaction simulates the dynamics of the well known internet sensation [2048](https://github.com/ialexryan/CS124-Project/blob/master/src/booter/README.md). We simulate the behavior (in this case, just that single interaction) until the system is stable for 50 interaction attempts in a row. This means that 50 successive interactions failed to react to form new molecules. After 50 interactions, it's almost certain that our simulation has reached the point where no more interaction can occur (though it could have just, by chance, tried interacting the wrong 2 molecules each of those 50 time).

Note that a `StochasticSystem` can use any `Hashable` type as its molecule—not just integers! Let's look at another example in which we simulate a stabilizing interaction until we reach a steady state.
```swift
// A whole lot of false values surrounding a scared, lonely true value.
var system = StochasticSystem(molecules: Array(Repeat(count: 50, repeatedValue: false)) + [true])

// true + true   -> true + false
// false + false -> false + true
let stabilizingInteraction = Interaction { a, b in
    guard a != b else { return nil }
    return [a, !a]
}

system.simulate(Behavior(stabilizingInteraction), stopping: .whenStable(streakLength: 70, absoluteTolerance: 2))
// If we check out system.molecules, we should see about 50% true values and 50% false values—try it!
```

Note that, even though both interactions we just looked at only delt with pairs of molecules, you can build interactions between an arbitrary number of molecules. For example, we can say three molecules interact such that the resulting molecules sum each of the pairs.
```swift
let pairSumInteraction = Interaction { a, b, c in 
    return [a + b, b + c, c + a]
}
```
Note that this super fancy intializer syntax is only provided for up to 6 molecules. Afterwards, you'll have to use the initializer that takes in a fixed length array of molecules rather than multiple arguments.

## Stopping Condition

Neat, right! What is this whole `whenStable` thing? Well, this is a `Condition` that determines when the simulation will stop. You can define you own, but we've got quite a few handy ones built in. For example, `whenStable(streakLength:)` will stop once `streakLength` interactions occur that do nothing. You can instead use `whenStable(streakLength:absoluteTolerance)` or `whenStable(streakLength:percentTolerance)` if you're okay with some changes (as will likely happen by random chance unless no interactions are possible), but still want to stop once it becomes relatively steady. You can also use `after(count:)` to make the simulation try a fixed number of interactions.

If you'd like to build your own stopping condition, just create an extension on the `Condition` type that adds an initializer for your own. You can base your condition on the initial state of the system as well as incremental deltas after each interaction.

## Behavior

So, we kinda glossed over something earlier. What's this whole `Behavior` initializer we sent our interaction into!? `Behavior` allows you to create more complicated stochastic processes by giving more control over which interaction will be run. The most basic `Behavior` initializer takes in a single interaction and runs *only* that one, over and over. `Behavior` however can be initialzed with multiple interactions such that one will be randomly chosen with each step of the simulation.
```swift
let compoundBehavior = Behavior(mergeInteraction, pairSumInteraction)
```
Even cooler, you can build your own custom behaviors that randomly generate interactions using your own secret sauce. For example, [Chemical](https://github.com/JadenGeller/Chemical) simulates the existance of rate constants in a system of chemical reactions by providing a behavior that chooses faster reactions with a higher probability than slower reactions.
