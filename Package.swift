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
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0")
    ],
    targets: [
        .executableTarget(
            name: "MarkdownPreviewer",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown")
            ],
            path: "Sources/MarkdownPreviewer"
        ),
        .testTarget(
            name: "MarkdownPreviewerTests",
            dependencies: ["MarkdownPreviewer"]
        )
    ]
)
