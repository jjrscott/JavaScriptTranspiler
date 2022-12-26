// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "JavaScriptTranspiler",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .plugin(name: "BuildTool", targets: ["BuildTool"]),
        .executable(name: "JavaScriptTranspiler", targets: ["JavaScriptTranspiler"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "JavaScriptTranspiler",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .plugin(
            name: "BuildTool",
            capability: .buildTool(),
            dependencies: [.target(name: "JavaScriptTranspiler")]
        ),
    ]
)
