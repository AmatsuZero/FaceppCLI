// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FaceppCLI",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/AmatsuZero/FaceppSwift.git", from: "0.1.4"),
        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FaceppCLI",
            dependencies: ["FaceppSwift", "SwiftGD", "ArgumentParser"]),
        .testTarget(
            name: "FaceppCLITests",
            dependencies: ["FaceppCLI"]),
    ]
)
