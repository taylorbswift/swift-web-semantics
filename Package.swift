// swift-tools-version:5.3
import PackageDescription

let package:Package = .init(
    name: "swift-web-semantics",
    products: 
    [
        .library(name: "MIME",          targets: ["MIME"]),
        .library(name: "WebResponse",   targets: ["WebResponse"]),
        .library(name: "WebSemantics",  targets: ["WebSemantics"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-hash.git", from: "0.2.3"),
    ],
    targets: 
    [
        .target(name: "MIME"),
        .target(name: "WebResponse", 
            dependencies: 
            [
                .target(name: "MIME"),
                .product(name: "SHA2", package: "swift-hash"),
            ]),
        .target(name: "WebSemantics", 
            dependencies: 
            [
                .target(name: "WebResponse"),
            ]),
    ]
)
