// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Symphony",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "Symphony", targets: ["Symphony"]),
    ],
    dependencies: [
        .package(url: "https://github.com/paulofaria/August.git", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        .target(name: "Symphony", dependencies: ["August"]),
    ]
)
