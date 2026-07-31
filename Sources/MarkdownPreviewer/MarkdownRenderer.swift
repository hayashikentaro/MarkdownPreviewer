import Foundation
import Markdown
import UniformTypeIdentifiers

struct MarkdownRenderer {
    func render(_ markdown: String, title: String, baseURL: URL? = nil) -> String {
        let document = Document(parsing: markdown)
        var renderer = RichHTMLRenderer(baseURL: baseURL)
        let body = renderer.visit(document)

        return """
        <!doctype html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\(Self.escape(title))</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/github.min.css" media="(prefers-color-scheme: light)">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/styles/github-dark.min.css" media="(prefers-color-scheme: dark)">
        <style>
        :root {
          color-scheme: light dark;
          --page-width: 860px;
          --paper: #ffffff;
          --ink: #1f2328;
          --muted: #6e7781;
          --border: #d0d7de;
          --code: #f6f8fa;
          --link: #0969da;
          --mark: #fff8c5;
        }
        @media (prefers-color-scheme: dark) {
          :root {
            --paper: #0d1117;
            --ink: #e6edf3;
            --muted: #8b949e;
            --border: #30363d;
            --code: #161b22;
            --link: #58a6ff;
            --mark: #3b3215;
          }
        }
        body {
          margin: 0;
          padding: 34px;
          background: color-mix(in srgb, var(--paper) 88%, var(--border));
          color: var(--ink);
          font: 16px/1.65 -apple-system, BlinkMacSystemFont, "Hiragino Sans", "Yu Gothic", sans-serif;
        }
        main {
          box-sizing: border-box;
          max-width: var(--page-width);
          min-height: calc(100vh - 68px);
          margin: 0 auto;
          padding: 54px 64px;
          background: var(--paper);
          border: 1px solid var(--border);
          border-radius: 14px;
          box-shadow: 0 18px 48px rgba(27, 31, 36, 0.16);
        }
        h1, h2, h3, h4, h5, h6 {
          line-height: 1.25;
          margin: 1.4em 0 0.55em;
        }
        h1:first-child, h2:first-child, h3:first-child { margin-top: 0; }
        h1 { font-size: 2em; padding-bottom: 0.25em; border-bottom: 1px solid var(--border); }
        h2 { font-size: 1.45em; padding-bottom: 0.2em; border-bottom: 1px solid var(--border); }
        h3 { font-size: 1.2em; }
        h4 { font-size: 1em; }
        h5 { font-size: 0.9em; }
        h6 { color: var(--muted); font-size: 0.85em; }
        p { margin: 0 0 1em; }
        a { color: var(--link); text-decoration-thickness: 0.08em; text-underline-offset: 0.16em; }
        img { max-width: 100%; border-radius: 8px; }
        mark { background: var(--mark); color: inherit; padding: 0 0.2em; border-radius: 3px; }
        .mermaid {
          display: flex;
          justify-content: center;
          overflow-x: auto;
          margin: 1em 0;
          padding: 16px;
          border: 1px solid var(--border);
          border-radius: 10px;
          background: var(--paper);
        }
        .mermaid svg {
          max-width: 100%;
          height: auto;
        }
        ul, ol { padding-left: 1.65em; margin: 0 0 1em; }
        li > ul, li > ol { margin-top: 0.25em; margin-bottom: 0.25em; }
        li > p { margin: 0.25em 0; }
        li.task-list-item {
          list-style: none;
          margin-left: -1.45em;
        }
        li.task-list-item > input[type="checkbox"] {
          width: 1em;
          height: 1em;
          margin: 0 0.45em 0 0;
          vertical-align: -0.12em;
        }
        li.task-list-item > input[type="checkbox"] + p {
          display: inline;
        }
        code {
          padding: 0.15em 0.35em;
          border-radius: 5px;
          background: var(--code);
          font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
          font-size: 0.92em;
        }
        pre {
          position: relative;
          overflow: auto;
          padding: 16px;
          border-radius: 10px;
          border: 1px solid var(--border);
          background: var(--code);
        }
        pre code {
          display: block;
          padding: 0;
          background: transparent;
        }
        pre[data-language] {
          padding-top: 34px;
        }
        pre[data-language]::before {
          content: attr(data-language);
          position: absolute;
          top: 8px;
          right: 12px;
          color: var(--muted);
          font: 12px/1 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
          text-transform: uppercase;
        }
        .code-copy {
          position: sticky;
          left: calc(100% - 58px);
          top: 0;
          z-index: 1;
          float: right;
          min-width: 48px;
          margin: -6px -6px 8px 12px;
          padding: 5px 8px;
          border: 1px solid var(--border);
          border-radius: 6px;
          background: var(--paper);
          color: var(--muted);
          font: 12px/1 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
          cursor: pointer;
        }
        .code-copy:hover {
          color: var(--ink);
          border-color: var(--muted);
        }
        .code-copy:focus-visible {
          outline: 2px solid var(--link);
          outline-offset: 2px;
        }
        blockquote {
          margin: 0 0 1em;
          padding: 0 1em;
          color: var(--muted);
          border-left: 4px solid var(--border);
        }
        blockquote > :last-child { margin-bottom: 0; }
        table {
          border-collapse: collapse;
          display: block;
          overflow-x: auto;
          width: max-content;
          max-width: 100%;
          margin: 1em 0;
        }
        th, td {
          padding: 6px 12px;
          border: 1px solid var(--border);
        }
        th {
          font-weight: 600;
          background: color-mix(in srgb, var(--code) 70%, transparent);
        }
        tr:nth-child(even) td {
          background: color-mix(in srgb, var(--code) 38%, transparent);
        }
        hr {
          height: 1px;
          border: 0;
          background: var(--border);
          margin: 2em 0;
        }
        @media (max-width: 700px) {
          body { padding: 0; }
          main {
            min-height: 100vh;
            padding: 28px 22px;
            border: 0;
            border-radius: 0;
            box-shadow: none;
          }
        }
        @media print {
          body { padding: 0; background: var(--paper); }
          main { border: 0; box-shadow: none; border-radius: 0; max-width: none; }
        }
        </style>
        </head>
        <body>
        <main>
        \(body)
        </main>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.11.1/highlight.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js"></script>
        <script>
        if (window.hljs) {
          document.querySelectorAll("pre code").forEach((block) => hljs.highlightElement(block));
        }
        if (window.mermaid) {
          const isDarkMode = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
          mermaid.initialize({
            startOnLoad: true,
            securityLevel: "strict",
            theme: isDarkMode ? "dark" : "default"
          });
        }
        document.querySelectorAll(".code-copy").forEach((button) => {
          button.addEventListener("click", async () => {
            const code = button.parentElement.querySelector("code");
            if (!code) return;

            try {
              await navigator.clipboard.writeText(code.textContent || "");
              button.textContent = "Copied";
              window.setTimeout(() => {
                button.textContent = "Copy";
              }, 1200);
            } catch {
              button.textContent = "Failed";
              window.setTimeout(() => {
                button.textContent = "Copy";
              }, 1200);
            }
          });
        });
        </script>
        </body>
        </html>
        """
    }

    fileprivate static func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}

private struct RichHTMLRenderer: MarkupVisitor {
    typealias Result = String

    let baseURL: URL?

    private var tableAlignments: [Table.ColumnAlignment?] = []
    private var currentTableColumn = 0
    private var slugCounts: [String: Int] = [:]

    init(baseURL: URL?) {
        self.baseURL = baseURL
    }

    mutating func visit(_ markup: Markup) -> String {
        markup.accept(&self)
    }

    mutating func defaultVisit(_ markup: Markup) -> String {
        renderChildren(of: markup)
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        block("blockquote", renderChildren(of: blockQuote))
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        let language = codeBlock.language?.trimmingCharacters(in: .whitespacesAndNewlines)
        if language?.lowercased() == "mermaid" {
            return "<div class=\"mermaid\">\(escape(codeBlock.code))</div>\n"
        }

        let languageClass = language.map { " class=\"language-\(escapeAttribute($0))\"" } ?? ""
        let languageAttribute = language.map { " data-language=\"\(escapeAttribute($0))\"" } ?? ""
        return "<pre\(languageAttribute)><button class=\"code-copy\" type=\"button\" aria-label=\"Copy code\">Copy</button><code\(languageClass)>\(escape(codeBlock.code))</code></pre>\n"
    }

    mutating func visitCustomBlock(_ customBlock: CustomBlock) -> String {
        renderChildren(of: customBlock)
    }

    mutating func visitDocument(_ document: Document) -> String {
        renderChildren(of: document)
    }

    mutating func visitHeading(_ heading: Heading) -> String {
        let content = renderChildren(of: heading)
        let id = uniqueSlug(for: heading.plainText)
        return "<h\(heading.level) id=\"\(escapeAttribute(id))\">\(content)</h\(heading.level)>\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
        "<hr>\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> String {
        "<pre><code>\(escape(html.rawHTML))</code></pre>\n"
    }

    mutating func visitListItem(_ listItem: ListItem) -> String {
        let checkboxHTML: String
        let className: String
        if let checkbox = listItem.checkbox {
            className = " class=\"task-list-item\""
            let checked = checkbox == .checked ? " checked" : ""
            checkboxHTML = "<input type=\"checkbox\" disabled\(checked)>"
        } else {
            className = ""
            checkboxHTML = ""
        }

        return "<li\(className)>\(checkboxHTML)\(renderChildren(of: listItem))</li>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        let start = orderedList.startIndex == 1 ? "" : " start=\"\(orderedList.startIndex)\""
        return block("ol\(start)", renderChildren(of: orderedList))
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        block("ul", renderChildren(of: unorderedList))
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        block("p", renderChildren(of: paragraph))
    }

    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> String {
        renderChildren(of: blockDirective)
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        "<code>\(escape(inlineCode.code))</code>"
    }

    mutating func visitCustomInline(_ customInline: CustomInline) -> String {
        renderChildren(of: customInline)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        inline("em", renderChildren(of: emphasis))
    }

    mutating func visitImage(_ image: Image) -> String {
        var attributes: [String] = []
        if let source = image.source, !source.isEmpty {
            attributes.append("src=\"\(escapeAttribute(resolvedImageSource(source)))\"")
        }
        if let title = image.title, !title.isEmpty {
            attributes.append("title=\"\(escapeAttribute(title))\"")
        }
        attributes.append("alt=\"\(escapeAttribute(image.plainText))\"")
        return "<img \(attributes.joined(separator: " "))>"
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> String {
        escape(inlineHTML.rawHTML)
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        "<br>\n"
    }

    mutating func visitLink(_ link: Link) -> String {
        var attributes: [String] = []
        if let destination = link.destination, !destination.isEmpty {
            attributes.append("href=\"\(escapeAttribute(destination))\"")
        }
        if let title = link.title, !title.isEmpty {
            attributes.append("title=\"\(escapeAttribute(title))\"")
        }
        let attributeString = attributes.isEmpty ? "" : " \(attributes.joined(separator: " "))"
        return "<a\(attributeString)>\(renderChildren(of: link))</a>"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        "\n"
    }

    mutating func visitStrong(_ strong: Strong) -> String {
        inline("strong", renderChildren(of: strong))
    }

    mutating func visitText(_ text: Text) -> String {
        escape(text.string)
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        inline("del", renderChildren(of: strikethrough))
    }

    mutating func visitTable(_ table: Table) -> String {
        let previousAlignments = tableAlignments
        tableAlignments = table.columnAlignments
        let html = block("table", renderChildren(of: table))
        tableAlignments = previousAlignments
        return html
    }

    mutating func visitTableHead(_ tableHead: Table.Head) -> String {
        currentTableColumn = 0
        return block("thead", block("tr", renderChildren(of: tableHead)))
    }

    mutating func visitTableBody(_ tableBody: Table.Body) -> String {
        guard !tableBody.isEmpty else { return "" }
        return block("tbody", renderChildren(of: tableBody))
    }

    mutating func visitTableRow(_ tableRow: Table.Row) -> String {
        currentTableColumn = 0
        return block("tr", renderChildren(of: tableRow))
    }

    mutating func visitTableCell(_ tableCell: Table.Cell) -> String {
        let tag = tableCell.parent is Table.Head ? "th" : "td"
        let alignment = currentTableColumn < tableAlignments.count ? tableAlignments[currentTableColumn] : nil
        currentTableColumn += 1

        var attributes: [String] = []
        if let alignment {
            attributes.append("align=\"\(alignment.htmlValue)\"")
        }
        if tableCell.rowspan > 1 {
            attributes.append("rowspan=\"\(tableCell.rowspan)\"")
        }
        if tableCell.colspan > 1 {
            attributes.append("colspan=\"\(tableCell.colspan)\"")
        }
        let attributeString = attributes.isEmpty ? "" : " \(attributes.joined(separator: " "))"
        return "<\(tag)\(attributeString)>\(renderChildren(of: tableCell))</\(tag)>\n"
    }

    mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> String {
        guard let destination = symbolLink.destination else { return "" }
        return "<code>\(escape(destination))</code>"
    }

    mutating func visitInlineAttributes(_ attributes: InlineAttributes) -> String {
        "<span data-attributes=\"\(escapeAttribute(attributes.attributes))\">\(renderChildren(of: attributes))</span>"
    }

    mutating func visitDoxygenDiscussion(_ doxygenDiscussion: DoxygenDiscussion) -> String {
        renderChildren(of: doxygenDiscussion)
    }

    mutating func visitDoxygenNote(_ doxygenNote: DoxygenNote) -> String {
        block("aside", renderChildren(of: doxygenNote))
    }

    mutating func visitDoxygenAbstract(_ doxygenAbstract: DoxygenAbstract) -> String {
        block("aside", renderChildren(of: doxygenAbstract))
    }

    mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> String {
        renderChildren(of: doxygenParam)
    }

    mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> String {
        renderChildren(of: doxygenReturns)
    }

    private mutating func renderChildren(of markup: Markup) -> String {
        markup.children.map { child in
            var renderer = self
            let html = renderer.visit(child)
            self = renderer
            return html
        }.joined()
    }

    private func block(_ tag: String, _ content: String) -> String {
        "<\(tag)>\n\(content)</\(tag.split(separator: " ").first ?? Substring(tag))>\n"
    }

    private func inline(_ tag: String, _ content: String) -> String {
        "<\(tag)>\(content)</\(tag)>"
    }

    private func escape(_ text: String) -> String {
        MarkdownRenderer.escape(text)
    }

    private func escapeAttribute(_ text: String) -> String {
        MarkdownRenderer.escape(text)
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    private mutating func uniqueSlug(for text: String) -> String {
        var slug = text.lowercased()
            .replacingOccurrences(of: #"[^a-z0-9\p{L}\p{N} -]"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: "-", options: .regularExpression)

        if slug.isEmpty {
            slug = "section"
        }

        let count = slugCounts[slug, default: 0]
        slugCounts[slug] = count + 1
        return count == 0 ? slug : "\(slug)-\(count)"
    }

    private func resolvedImageSource(_ source: String) -> String {
        guard
            let baseURL,
            baseURL.isFileURL,
            isRelativeImageSource(source),
            let imageURL = localImageURL(for: source, relativeTo: baseURL),
            let data = try? Data(contentsOf: imageURL)
        else {
            return source
        }

        let mimeType = Self.mimeType(for: imageURL)
        return "data:\(mimeType);base64,\(data.base64EncodedString())"
    }

    private func isRelativeImageSource(_ source: String) -> Bool {
        guard !source.hasPrefix("#"), !source.hasPrefix("/") else {
            return false
        }

        if let url = URL(string: source), url.scheme != nil {
            return false
        }

        return true
    }

    private func localImageURL(for source: String, relativeTo baseURL: URL) -> URL? {
        let path = source
            .split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)[0]
            .split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)[0]

        guard !path.isEmpty else {
            return nil
        }

        let decodedPath = String(path).removingPercentEncoding ?? String(path)
        return baseURL.appendingPathComponent(decodedPath).standardizedFileURL
    }

    private static func mimeType(for url: URL) -> String {
        if let type = UTType(filenameExtension: url.pathExtension),
           let mimeType = type.preferredMIMEType {
            return mimeType
        }

        return "application/octet-stream"
    }
}

private extension Table.ColumnAlignment {
    var htmlValue: String {
        switch self {
        case .left:
            return "left"
        case .center:
            return "center"
        case .right:
            return "right"
        }
    }
}
