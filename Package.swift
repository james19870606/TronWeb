// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TronWeb",
    products: [
        .library(
            name: "TronWeb",
            targets: ["TronWeb"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "TronWeb",
            dependencies: [],
            resources: [
                .copy("TronWeb.bundle")
            ]
        )
    ]
)
