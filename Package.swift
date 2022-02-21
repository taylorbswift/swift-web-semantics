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
    ],
    targets: 
    [
        .target(name: "Resource", 
            path: "sources/resource", 
            exclude: 
            [
            ]),
    ]
)
