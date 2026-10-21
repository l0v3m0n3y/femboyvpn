// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "femboyvpn",
    platforms: [
        .macOS(.v12), .iOS(.v15)
    ],
    products: [
        .library(name: "femboyvpn", targets: ["femboyvpn"]),
    ],
    targets: [
        .target(
            name: "femboyvpn",
            path: "src"
        ),
    ]
)
