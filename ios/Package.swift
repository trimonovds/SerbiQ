// swift-tools-version: 5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "serbiq-ios",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "App",
      targets: ["App"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.17.1"
    ),
    .package(name: "serbiq-shared", path: "../shared"),
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(name: "Domain", package: "serbiq-shared"),
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        "App",
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
  ]
)
