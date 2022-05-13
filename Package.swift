// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "swift-resource",
    products: 
    [
        .library(name: "Resource",          targets: ["Resource"]),
        .library(name: "VersionControl",    targets: ["VersionControl"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/apple/swift-system.git", from: "1.1.1"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.1.0")
    ],
    targets: 
    [
        .target(name: "VersionControl", 
            dependencies: 
            [
                .target(name: "Resource"),
                .product(name: "SwiftShell", package: "SwiftShell"),
                .product(name: "SystemPackage", package: "swift-system"),
            ],
            path: "sources/version-control", 
            exclude: 
            [
            ]),
        .target(name: "Resource", 
            dependencies: [],
            path: "sources/resource", 
            exclude: 
            [
            ]),
    ]
)
