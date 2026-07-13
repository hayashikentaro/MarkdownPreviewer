# MarkdownPreviewer

Markdown files can be previewed in a simple native macOS window with a paper-like layout.

## Run

```sh
swift run MarkdownPreviewer
```

Then use `Command-O`, the `Open...` button, or drag a `.md` file onto the window.

## Build a Standalone App

```sh
scripts/build-app.sh
```

The standalone app is written to `dist/Markdown Previewer.app`.

To regenerate the app icon:

```sh
scripts/build-icon.sh
```

## Features

- Native SwiftUI macOS app
- Paper-like preview using WebKit rendering
- Local relative image support for Markdown files, including GitHub-style README asset paths
- `Command-O` to open files
- `Command-R` to reload
- Automatic reload when the opened file changes
- CommonMark/GFM rendering powered by `swift-markdown`
- Tables, ordered and nested lists, task lists, strikethrough, autolinks, reference links, heading anchors, and fenced code languages
- Syntax highlighting and copy buttons for code blocks when the bundled WebKit view can load highlight.js from the CDN
