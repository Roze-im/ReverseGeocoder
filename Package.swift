// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReverseGeocoder",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v15),
        .macCatalyst(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ReverseGeocoder",
            targets: ["ReverseGeocoder"]),
        .library(
            name: "ReverseGeocoderTesting",
            targets: ["ReverseGeocoderTesting"]),
    ],
    dependencies: [
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ReverseGeocoder",
            dependencies: [
            ]
        ),
        .target(
            name: "ReverseGeocoderTesting",
            dependencies: [
                .byName(name: "ReverseGeocoder"),
            ]
        ),
        .testTarget(
            name: "ReverseGeocoderTests",
            dependencies: ["ReverseGeocoder", "ReverseGeocoderTesting"]),
    ]
)
