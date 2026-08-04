// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CountdownKit",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10)],
    products: [
        .library(name: "CountdownKit", targets: ["CountdownKit"])
    ],
    targets: [
        .target(name: "CountdownKit", resources: [.process("Resources")]),
        .testTarget(name: "CountdownKitTests", dependencies: ["CountdownKit"])
    ]
)
