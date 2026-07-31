import XCTest
@testable import MarkdownPreviewer

final class MarkdownRendererTests: XCTestCase {
    func testRendersGitHubFlavoredMarkdown() {
        let markdown = """
        # Main Title

        1. First
        2. Second

        - [x] Done
        - [ ] Pending

        | Name | Count |
        | :--- | ----: |
        | Apples | 3 |

        ~~Removed~~

        ```swift
        let value = 42
        ```
        """

        let html = MarkdownRenderer().render(markdown, title: "Sample")

        XCTAssertTrue(html.contains(#"<h1 id="main-title">Main Title</h1>"#))
        XCTAssertTrue(html.contains("<ol>"))
        XCTAssertTrue(html.contains(#"<li class="task-list-item"><input type="checkbox" disabled checked>"#))
        XCTAssertTrue(html.contains(#"<li class="task-list-item"><input type="checkbox" disabled>"#))
        XCTAssertTrue(html.contains("<table>"))
        XCTAssertTrue(html.contains(#"<th align="left">Name</th>"#))
        XCTAssertTrue(html.contains(#"<td align="right">3</td>"#))
        XCTAssertTrue(html.contains("<del>Removed</del>"))
        XCTAssertTrue(html.contains(#"<pre data-language="swift"><button class="code-copy" type="button" aria-label="Copy code">Copy</button><code class="language-swift">let value = 42"#))
        XCTAssertTrue(html.contains("navigator.clipboard.writeText"))
    }

    func testEscapesRegularTextAndAttributes() {
        let markdown = """
        # A < B

        ## Repeat
        ## Repeat

        [bad](https://example.com/?q="<tag>")

        `<script>`
        """

        let html = MarkdownRenderer().render(markdown, title: #"A "Title""#)

        XCTAssertTrue(html.contains("<title>A &quot;Title&quot;</title>"))
        XCTAssertTrue(html.contains(#"<h1 id="a-b">A &lt; B</h1>"#))
        XCTAssertTrue(html.contains(#"<h2 id="repeat">Repeat</h2>"#))
        XCTAssertTrue(html.contains(#"<h2 id="repeat-1">Repeat</h2>"#))
        XCTAssertTrue(html.contains(#"href="https://example.com/?q=&quot;&lt;tag&gt;&quot;""#))
        XCTAssertTrue(html.contains("<code>&lt;script&gt;</code>"))
    }

    func testEmbedsLocalRelativeImagesAsDataURLs() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let assetsDirectory = directory.appendingPathComponent("assets", isDirectory: true)
        try FileManager.default.createDirectory(at: assetsDirectory, withIntermediateDirectories: true)

        let imageData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=")!
        try imageData.write(to: assetsDirectory.appendingPathComponent("logo.png"))

        let markdown = """
        ![Logo](assets/logo.png)
        ![Remote](https://example.com/remote.png)
        """

        let html = MarkdownRenderer().render(markdown, title: "Images", baseURL: directory)

        XCTAssertTrue(html.contains(#"src="data:image/png;base64,"#))
        XCTAssertTrue(html.contains(imageData.base64EncodedString()))
        XCTAssertTrue(html.contains(#"alt="Logo""#))
        XCTAssertTrue(html.contains(#"src="https://example.com/remote.png""#))
    }

    func testRendersMermaidCodeBlocksAsDiagrams() {
        let markdown = """
        ```mermaid
        flowchart TD
            A[Start] --> B{Ready?}
            B -- Yes --> C[Render]
        ```
        """

        let html = MarkdownRenderer().render(markdown, title: "Mermaid")

        XCTAssertTrue(html.contains(#"<script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>"#))
        XCTAssertTrue(html.contains(#"mermaid.initialize"#))
        XCTAssertTrue(html.contains(#"<div class="mermaid">flowchart TD"#))
        XCTAssertTrue(html.contains(#"A[Start] --&gt; B{Ready?}"#))
        XCTAssertFalse(html.contains(#"<pre data-language="mermaid">"#))
        XCTAssertFalse(html.contains(#"<code class="language-mermaid">"#))
    }

    func testDoesNotExecuteRawHTMLFromMarkdown() {
        let markdown = """
        <script>window.evil = true</script>

        Text with <img src=x onerror="window.evil = true"> inline HTML.
        """

        let html = MarkdownRenderer().render(markdown, title: "Untrusted")

        XCTAssertFalse(html.contains("<script>window.evil"))
        XCTAssertFalse(html.contains("<img src=x"))
        XCTAssertTrue(html.contains("&lt;script&gt;window.evil = true&lt;/script&gt;"))
        XCTAssertTrue(html.contains("&lt;img src=x onerror=&quot;window.evil = true&quot;&gt;"))
    }
}
