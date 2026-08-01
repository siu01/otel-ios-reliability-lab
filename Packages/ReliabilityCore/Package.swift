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
    ],
    targets: [
        .target(name: "ReliabilityCore"),
        .testTarget(
            name: "ReliabilityCoreTests",
            dependencies: ["ReliabilityCore"]
        ),
    ]
)

