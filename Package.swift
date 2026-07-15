// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SwiftUIDemo",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SwiftUIDemo", targets: ["SwiftUIDemo"])
    ],
    targets: [
        .executableTarget(
            name: "SwiftUIDemo",
            path: "Sources/SwiftUIDemo"
        ),
        .testTarget(
            name: "SwiftUIDemoTests",
            dependencies: ["SwiftUIDemo"],
            path: "Tests/SwiftUIDemoTests"
        )
    ]
)
