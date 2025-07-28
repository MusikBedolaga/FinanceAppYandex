// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Utilities",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "PieChart", targets: ["PieChart"]),
        .library(name: "Splash", targets: ["Splash"])
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.2.0")
    ],
    targets: [
        .target(
            name: "PieChart",
            dependencies: []
        ),
        .target(
            name: "Splash",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios")
            ]
        ),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["PieChart"]
        )
    ]
)
