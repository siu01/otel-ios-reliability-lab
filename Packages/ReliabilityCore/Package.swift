// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ReliabilityCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "ReliabilityCore", targets: ["ReliabilityCore"]),
        .executable(name: "reliability-reconcile", targets: ["ReliabilityCLI"]),
    ],
    targets: [
        .target(name: "ReliabilityCore"),
        .executableTarget(
            name: "ReliabilityCLI",
            dependencies: ["ReliabilityCore"]
        ),
        .testTarget(
            name: "ReliabilityCoreTests",
            dependencies: ["ReliabilityCore"]
        ),
    ]
)
