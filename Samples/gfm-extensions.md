# GFM Extension Check

This file covers common Markdown and GitHub-flavored Markdown cases used by the previewer.

## Task Lists

- [x] Open a local file
- [x] Render tables
- [x] Render Mermaid diagrams
- [ ] Export preview output

## Tables

| Feature | Status | Notes |
| :--- | :---: | ---: |
| Tables | OK | 3 columns |
| Task lists | OK | checkbox input |
| Mermaid | OK | diagram rendering |

## Text Styles

Normal text with **strong**, *emphasis*, ~~strikethrough~~, `inline code`, and a [reference link][repo].

The same heading appears twice to verify unique heading anchors.

### Repeated Heading

First section.

### Repeated Heading

Second section.

## Lists

1. Ordered item
2. Ordered item with nested bullets
   - child item
   - child item with `code`
3. Ordered item after nesting

## Blockquote

> A blockquote with **formatting**.
>
> - Nested list item
> - Another nested list item

## Code Blocks

```swift
struct Sample {
    let title: String
    let count: Int
}
```

```json
{
  "name": "MarkdownPreviewer",
  "features": ["tables", "tasks", "syntax-highlight"]
}
```

## Raw HTML Safety

<mark>Highlighted text via inline HTML</mark>

<details>
<summary>Expandable HTML block</summary>

This verifies that raw HTML is displayed as text instead of being executed.

</details>

## Escaping

Characters that should be escaped in normal text: <script>alert("xss")</script>

[repo]: https://github.com/
