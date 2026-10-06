# MarkdownPreviewer

MarkdownPreviewer is a native macOS viewer for Markdown and MDZip (`.mdz`) documents. It renders local files in a paper-like WebKit preview and keeps packaged images and linked Markdown pages available when opening MDZip archives.

## Requirements

- macOS 13 Ventura or later
- Xcode Command Line Tools when building from source

## Supported Files

- Markdown: `.md`, `.markdown`, and plain-text Markdown files
- MDZip 1.x: `.mdz` archives containing Markdown, assets, and an optional `manifest.json`

## Usage

Open a document with the Open button, drag it onto the window, or use the File menu.

| Shortcut | Action |
| :--- | :--- |
| `Command-O` | Open Markdown or MDZip |
| `Command-R` | Reload the current document |
| `Command-P` | Print or save the current page as PDF |

When viewing an MDZip archive, use the document menu in the toolbar or internal Markdown links to move between packaged pages. Printing outputs the currently displayed page.

## Features

- Native SwiftUI macOS application
- Universal 2 binary for Intel and Apple Silicon Macs
- CommonMark and GitHub-flavored Markdown rendering with tables, task lists, strikethrough, autolinks, and heading anchors
- Local and packaged relative images embedded into the preview
- Mermaid fenced-block diagram rendering
- Syntax highlighting and copy buttons for fenced code blocks
- Automatic reload when the source file changes
- macOS Page Setup and Print panels with PDF output
- MDZip manifest and entry-point resolution
- MDZip multi-document navigation and internal links
- Archive validation for unsafe paths, symbolic links, excessive sizes, and suspicious compression ratios
- Raw HTML displayed safely instead of being executed

## Run from Source

```sh
swift run MarkdownPreviewer
```

## Test

```sh
swift test
```

Manual Markdown samples and an MDZip validation archive are available in `Samples/`.

## Build the App

```sh
scripts/build-app.sh
```

The application is written to:

```text
dist/Markdown Previewer.app
```

The build script produces a Universal 2 executable containing both `x86_64` and `arm64` architectures.

The default build uses an ad-hoc signature. To use a Developer ID Application certificate, provide its full identity:

```sh
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" scripts/build-app.sh
```

## Build the DMG

```sh
scripts/build-dmg.sh
```

Version `0.1.0` produces:

```text
dist/MarkdownPreviewer-0.1.0.dmg
dist/MarkdownPreviewer-0.1.0.dmg.sha256
```

The DMG contains `Markdown Previewer.app` and an `Applications` shortcut. Drag the app onto `Applications` to install it.

Verify the downloaded artifact with:

```sh
cd dist
shasum -a 256 -c MarkdownPreviewer-0.1.0.dmg.sha256
```

For a signed and notarized public release, configure a Developer ID Application certificate and a `notarytool` keychain profile:

```sh
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
NOTARY_PROFILE="notary-profile" \
scripts/build-dmg.sh
```

Without Developer ID signing and notarization, macOS may block a downloaded copy. For local testing, remove the quarantine attribute if necessary:

```sh
xattr -dr com.apple.quarantine "/Applications/Markdown Previewer.app"
```

## Regenerate the App Icon

```sh
scripts/build-icon.sh
```
