// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "swift-resource",
    products: 
    [
        .library    (name: "Resource", targets: ["Resource"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/apple/swift-system.git", from: "1.1.1"),
    ],
    targets: 
    [
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
