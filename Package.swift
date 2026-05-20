// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "dawn-reference-app-fuse",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v14)],
    products: [
        .library(name: "DawnReferenceAppFuse", type: .dynamic, targets: ["DawnReferenceAppFuse"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.8.2"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
        .package(url: "https://source.skip.dev/skip-av.git", from: "0.7.0"),
        .package(url: "https://source.skip.dev/skip-kit.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "DawnReferenceAppFuse", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
            .product(name: "SkipAV", package: "skip-av"),
            .product(name: "SkipKit", package: "skip-kit")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
