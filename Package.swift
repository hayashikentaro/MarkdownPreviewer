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
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.20")
    ],
    targets: [
        .executableTarget(
            name: "MarkdownPreviewer",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Sources/MarkdownPreviewer"
        ),
        .testTarget(
            name: "MarkdownPreviewerTests",
            dependencies: [
                "MarkdownPreviewer",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ]
        )
    ]
)
