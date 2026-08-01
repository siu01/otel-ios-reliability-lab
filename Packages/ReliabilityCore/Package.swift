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
        .executable(name: "reliability-partition-cost", targets: ["PartitionCostCLI"]),
        .executable(name: "reliability-payload-order-cost", targets: ["PayloadOrderCostCLI"]),
    ],
    targets: [
        .target(name: "ReliabilityCore"),
        .executableTarget(
            name: "ReliabilityCLI",
            dependencies: ["ReliabilityCore"]
        ),
        .executableTarget(
            name: "PartitionCostCLI",
            dependencies: ["ReliabilityCore"]
        ),
        .executableTarget(
            name: "PayloadOrderCostCLI",
            dependencies: ["ReliabilityCore"]
        ),
        .testTarget(
            name: "ReliabilityCoreTests",
            dependencies: ["ReliabilityCore"]
        ),
    ]
)
