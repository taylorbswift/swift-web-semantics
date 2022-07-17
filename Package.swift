// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "swift-resource",
    products: 
    [
        .library(name: "MIME",          targets: ["MIME"]),
        .library(name: "Resources",     targets: ["Resources"]),
        .library(name: "SystemExtras",  targets: ["SystemExtras"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-hash.git", from: "0.2.2"),
        .package(url: "https://github.com/apple/swift-system.git",  from: "1.2.1"),
    ],
    targets: 
    [
        .target(name: "MIME"),
        .target(name: "Resources", 
            dependencies: 
            [
                .target(name: "MIME"),
                .product(name: "SHA2", package: "swift-hash"),
            ]),
        .target(name: "SystemExtras", 
            dependencies: 
            [
                .product(name: "SystemPackage", package: "swift-system"),
            ]),
    ]
)
