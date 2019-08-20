// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ShellKit",
    products: [
        .library(name: "ShellKit", targets: ["ShellKit"]),
        .library(name: "SSHShell", targets: ["SSHShell"]),
        .library(name: "LocalShell", targets: ["LocalShell"]),
        .library(name: "CommandKit", targets: ["CommandKit"]),
        .library(name: "ExecutorMocks", targets: ["ExecutorMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.3.0"),
        .package(url: "https://github.com/Einstore/WebErrorKit.git", from: "0.0.1"),
        .package(url: "https://github.com/Einstore/Shout.git", from: "0.5.1")
    ],
    targets: [
        .target(
            name: "ShellKit",
            dependencies: [
                "SSHShell",
                "LocalShell",
                "NIO"
            ]
        ),
        .target(
            name: "SSHShell",
            dependencies: [
                "Shout",
                "ExecutorKit",
                "NIO"
            ]
        ),
        .target(
            name: "LocalShell",
            dependencies: [
                "ExecutorKit",
                "NIO",
                "WebErrorKit"
            ]
        ),
        .target(
            name: "ExecutorKit",
            dependencies: [
                "Shout",
                "NIO",
                "WebErrorKit"
            ]
        ),
        .target(
            name: "CommandKit",
            dependencies: [
                "ShellKit",
                "WebErrorKit"
            ]
        ),
        .target(
            name: "ExecutorMocks",
            dependencies: [
                "ExecutorKit"
            ]
        ),
        .testTarget(
            name: "LocalShellTests",
            dependencies: [
                "LocalShell",
                "NIO"
            ]
        ),
        .testTarget(
            name: "CommandKitTests",
            dependencies: [
                "CommandKit",
                "NIO"
            ]
        )
    ]
)
