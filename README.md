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

## Features

- Native SwiftUI macOS app
- Paper-like preview using WebKit rendering
- Local image support via the Markdown file's folder as the base URL
- `Command-O` to open files
- `Command-R` to reload
- Automatic reload when the opened file changes
- Basic Markdown support: headings, paragraphs, unordered lists, blockquotes, code fences, links, images, inline code, bold, and emphasis
