import Foundation

struct MarkdownRenderer {
    func render(_ markdown: String, title: String) -> String {
        """
        <!doctype html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\(escape(title))</title>
        <style>
        :root {
          color-scheme: light dark;
          --page-width: 820px;
          --paper: #ffffff;
          --ink: #1f2328;
          --muted: #6e7781;
          --border: #d0d7de;
          --code: #f6f8fa;
          --link: #0969da;
        }
        @media (prefers-color-scheme: dark) {
          :root {
            --paper: #0d1117;
            --ink: #e6edf3;
            --muted: #8b949e;
            --border: #30363d;
            --code: #161b22;
            --link: #58a6ff;
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
        p { margin: 0 0 1em; }
        a { color: var(--link); }
        img { max-width: 100%; border-radius: 8px; }
        code {
          padding: 0.15em 0.35em;
          border-radius: 5px;
          background: var(--code);
          font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
          font-size: 0.92em;
        }
        pre {
          overflow: auto;
          padding: 16px;
          border-radius: 10px;
          border: 1px solid var(--border);
          background: var(--code);
        }
        pre code { padding: 0; background: transparent; }
        blockquote {
          margin: 0 0 1em;
          padding: 0 1em;
          color: var(--muted);
          border-left: 4px solid var(--border);
        }
        table {
          border-collapse: collapse;
          display: block;
          overflow-x: auto;
          margin: 1em 0;
        }
        th, td {
          padding: 6px 12px;
          border: 1px solid var(--border);
        }
        hr {
          height: 1px;
          border: 0;
          background: var(--border);
          margin: 2em 0;
        }
        @media print {
          body { padding: 0; background: var(--paper); }
          main { border: 0; box-shadow: none; border-radius: 0; max-width: none; }
        }
        </style>
        </head>
        <body>
        <main>
        \(renderBlocks(markdown))
        </main>
        </body>
        </html>
        """
    }

    private func renderBlocks(_ markdown: String) -> String {
        let lines = markdown.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        var html: [String] = []
        var paragraph: [String] = []
        var listItems: [String] = []
        var inCodeBlock = false
        var codeLines: [String] = []

        func flushParagraph() {
            guard !paragraph.isEmpty else { return }
            html.append("<p>\(inline(paragraph.joined(separator: " ")))</p>")
            paragraph.removeAll()
        }

        func flushList() {
            guard !listItems.isEmpty else { return }
            html.append("<ul>\(listItems.joined())</ul>")
            listItems.removeAll()
        }

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespaces)

            if line.hasPrefix("```") {
                if inCodeBlock {
                    html.append("<pre><code>\(escape(codeLines.joined(separator: "\n")))</code></pre>")
                    codeLines.removeAll()
                    inCodeBlock = false
                } else {
                    flushParagraph()
                    flushList()
                    inCodeBlock = true
                }
                continue
            }

            if inCodeBlock {
                codeLines.append(rawLine)
                continue
            }

            if line.isEmpty {
                flushParagraph()
                flushList()
                continue
            }

            if line == "---" || line == "***" {
                flushParagraph()
                flushList()
                html.append("<hr>")
                continue
            }

            if let heading = heading(from: line) {
                flushParagraph()
                flushList()
                html.append(heading)
                continue
            }

            if line.hasPrefix(">") {
                flushParagraph()
                flushList()
                let text = line.dropFirst().trimmingCharacters(in: .whitespaces)
                html.append("<blockquote>\(inline(String(text)))</blockquote>")
                continue
            }

            if let item = unorderedListItem(from: line) {
                flushParagraph()
                listItems.append("<li>\(inline(item))</li>")
                continue
            }

            paragraph.append(line)
        }

        if inCodeBlock {
            html.append("<pre><code>\(escape(codeLines.joined(separator: "\n")))</code></pre>")
        }
        flushParagraph()
        flushList()

        return html.joined(separator: "\n")
    }

    private func heading(from line: String) -> String? {
        let markerCount = line.prefix(while: { $0 == "#" }).count
        guard markerCount > 0, markerCount <= 6 else { return nil }
        let rest = line.dropFirst(markerCount)
        guard rest.first == " " else { return nil }
        return "<h\(markerCount)>\(inline(String(rest.dropFirst())))</h\(markerCount)>"
    }

    private func unorderedListItem(from line: String) -> String? {
        for prefix in ["- ", "* ", "+ "] where line.hasPrefix(prefix) {
            return String(line.dropFirst(prefix.count))
        }
        return nil
    }

    private func inline(_ text: String) -> String {
        var result = escape(text)
        result = replaceImages(in: result)
        result = replaceLinks(in: result)
        result = replaceDelimited("`", tag: "code", in: result)
        result = replaceDelimited("**", tag: "strong", in: result)
        result = replaceDelimited("*", tag: "em", in: result)
        return result
    }

    private func replaceImages(in text: String) -> String {
        replacePattern(#"!\[([^\]]*)\]\(([^)]+)\)"#, in: text) { matches in
            "<img alt=\"\(matches[1])\" src=\"\(matches[2])\">"
        }
    }

    private func replaceLinks(in text: String) -> String {
        replacePattern(#"\[([^\]]+)\]\(([^)]+)\)"#, in: text) { matches in
            "<a href=\"\(matches[2])\">\(matches[1])</a>"
        }
    }

    private func replaceDelimited(_ delimiter: String, tag: String, in text: String) -> String {
        let escapedDelimiter = NSRegularExpression.escapedPattern(for: delimiter)
        let pattern = "\(escapedDelimiter)(.+?)\(escapedDelimiter)"
        return replacePattern(pattern, in: text) { matches in
            "<\(tag)>\(matches[1])</\(tag)>"
        }
    }

    private func replacePattern(_ pattern: String, in text: String, transform: ([String]) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length)).reversed()
        var result = text

        for match in matches {
            var captures: [String] = []
            for index in 0..<match.numberOfRanges {
                captures.append(nsText.substring(with: match.range(at: index)))
            }
            let replacement = transform(captures)
            if let range = Range(match.range, in: result) {
                result.replaceSubrange(range, with: replacement)
            }
        }

        return result
    }

    private func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
