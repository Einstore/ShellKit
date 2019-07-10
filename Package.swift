// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ShellKit",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "ShellKit", targets: ["ShellKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.3.0"),
        .package(url: "https://github.com/jakeheis/Shout.git", from: "0.5.0"),
        .package(url: "https://github.com/kareman/SwiftShell.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "ShellKit",
            dependencies: [
                "Shout",
                "SwiftShell",
                "NIO"
            ]
        )
    ]
)


