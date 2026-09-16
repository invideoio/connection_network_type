// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "connection_network_type",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // The library name is the hyphenated plugin name, as required by the Flutter tool.
        .library(name: "connection-network-type", targets: ["connection_network_type"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.2.4")
    ],
    targets: [
        .target(
            name: "connection_network_type",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Reachability", package: "Reachability.swift")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
