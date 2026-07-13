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
}
