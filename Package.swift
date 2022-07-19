// swift-tools-version:5.5
import PackageDescription

#if os(Linux) || os(macOS) || os(Windows)
let dependencies:[Package.Dependency] = 
[
    .package(url: "https://github.com/apple/swift-system.git",  from: "1.2.1"),
]
let products:[Product] = 
[
    .library(name: "SystemExtras",  targets: ["SystemExtras"]),
]
let targets:[Target] = 
[
    .target(name: "SystemExtras", 
        dependencies: 
        [
            .product(name: "SystemPackage", package: "swift-system"),
        ]),
]
#else 
let dependencies:[Package.Dependency] = []
let products:[Product] = []
let targets:[Target] = []
#endif 

let package:Package = .init(
    name: "swift-resource",
    products: products +
    [
        .library(name: "MIME",          targets: ["MIME"]),
        .library(name: "Resources",     targets: ["Resources"]),
        .library(name: "WebSemantics",  targets: ["WebSemantics"]),
    ],
    dependencies: dependencies +
    [
        .package(url: "https://github.com/kelvin13/swift-hash.git", from: "0.2.2"),
    ],
    targets: targets +
    [
        .target(name: "MIME"),
        .target(name: "Resources", 
            dependencies: 
            [
                .target(name: "MIME"),
                .product(name: "SHA2", package: "swift-hash"),
            ]),
        .target(name: "WebSemantics"),
    ]
)
