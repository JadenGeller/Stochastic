
import PackageDescription

let package = Package(
    name: "Stochastic",
    dependencies: [
        .Package(url: "https://github.com/JadenGeller/Erratic.git", majorVersion: 1)
    ]
)
