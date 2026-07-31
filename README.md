# MarkdownPreviewer

Markdown and MDZip (`.mdz`) files can be previewed in a simple native macOS window with a paper-like layout.

## Run

```sh
swift run MarkdownPreviewer
```

Then use `Command-O`, the `Open...` button, or drag a `.md` or `.mdz` file onto the window.

## Build a Standalone App

```sh
scripts/build-app.sh
```

The standalone app is written to `dist/Markdown Previewer.app`.

To create a release zip:

```sh
ditto -c -k --keepParent "dist/Markdown Previewer.app" "dist/MarkdownPreviewer-0.2.0.zip"
```

If macOS blocks the app because it was downloaded from the internet or copied from another machine, remove the quarantine attribute before opening it:

```sh
xattr -dr com.apple.quarantine "Markdown Previewer.app"
```

To regenerate the app icon:

```sh
scripts/build-icon.sh
```

## Features

- Native SwiftUI macOS app
- Paper-like preview using WebKit rendering
- Local relative image support for Markdown files, including GitHub-style README asset paths
- MDZip 1.x support with manifests, packaged images, multiple Markdown files, and internal document links
- MDZip archive safety checks for unsafe paths, symbolic links, excessive sizes, and suspicious compression ratios
- `Command-O` to open files
- `Command-R` to reload
- `Command-P` to print or save the current document as PDF using the macOS print panel
- Automatic reload when the opened file changes
- CommonMark/GFM rendering powered by `swift-markdown`
- Tables, ordered and nested lists, task lists, strikethrough, autolinks, reference links, heading anchors, and fenced code languages
- Mermaid diagram rendering for `mermaid` fenced code blocks
- Syntax highlighting and copy buttons for code blocks when the bundled WebKit view can load highlight.js from the CDN
