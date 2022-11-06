// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepFoodSearch",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrepFoodSearch",
            targets: ["PrepFoodSearch"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/FoodLabel", from: "0.0.29"),
        .package(url: "https://github.com/pxlshpr/PrepDataTypes", from: "0.0.109"),
        .package(url: "https://github.com/pxlshpr/PrepNetworkController", from: "0.0.22"),
        .package(url: "https://github.com/pxlshpr/PrepViews", from: "0.0.21"),
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.86"),
        .package(url: "https://github.com/pxlshpr/SwiftUICamera", from: "0.0.35"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.219"),
        .package(url: "https://github.com/exyte/ActivityIndicatorView", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepFoodSearch",
            dependencies: [
                .product(name: "Camera", package: "swiftuicamera"),
                .product(name: "PrepDataTypes", package: "prepdatatypes"),
                .product(name: "PrepNetworkController", package: "prepnetworkcontroller"),
                .product(name: "PrepViews", package: "prepviews"),
                .product(name: "SwiftSugar", package: "swiftsugar"),
                .product(name: "FoodLabel", package: "foodlabel"),
                .product(name: "ActivityIndicatorView", package: "activityindicatorview"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),

            ]),
        .testTarget(
            name: "PrepFoodSearchTests",
            dependencies: ["PrepFoodSearch"]),
    ]
)
