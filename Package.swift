// swift-tools-version:5.5
import PackageDescription

let package:Package = .init(
    name: "swift-resource",
    products: 
    [
        .library(name: "MIME",          targets: ["MIME"]),
        .library(name: "Resources",     targets: ["Resources"]),
        .library(name: "WebSemantics",  targets: ["WebSemantics"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-hash.git", from: "0.2.3"),
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
        .target(name: "WebSemantics"),
    ]
)
