// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "serbiq-backend",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(
            url: "https://github.com/pointfreeco/swift-identified-collections.git",
            from: "1.1.0"
        ),
        .package(name: "serbiq-shared", path: "../shared"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Domain", package: "serbiq-shared"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ]
        )
    ]
)
