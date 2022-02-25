// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "swift-resource",
    products: 
    [
        .library    (name: "Resource",      targets: ["Resource"]),
        .library    (name: "Bureaucrat",    targets: ["Bureaucrat"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/apple/swift-system.git",      from: "1.1.1"),
        .package(url: "https://github.com/kareman/SwiftShell",          from: "5.1.0")
    ],
    targets: 
    [
        .target(name: "Bureaucrat", 
            dependencies: 
            [
                .product(name: "SwiftShell", package: "SwiftShell"),
                .target(name: "Resource"),
            ],
            path: "sources/bureaucrat", 
            exclude: 
            [
            ]),
        .target(name: "Resource", 
            dependencies: 
            [
                .product(name: "SystemPackage", package: "swift-system"),
            ],
            path: "sources/resource", 
            exclude: 
            [
            ]),
    ]
)
