// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "CountdownKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CountdownKit", targets: ["CountdownKit"])
    ],
    targets: [
        .target(name: "CountdownKit"),
        .testTarget(name: "CountdownKitTests", dependencies: ["CountdownKit"])
    ]
)
