// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MarkdownPreviewer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MarkdownPreviewer", targets: ["MarkdownPreviewer"])
    ],
    targets: [
        .executableTarget(
            name: "MarkdownPreviewer",
            path: "Sources/MarkdownPreviewer"
        )
    ]
)
