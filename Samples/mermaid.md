# Mermaid Preview Cases

This file is for checking how Mermaid fenced blocks are displayed in the previewer.
If Mermaid rendering is added later, each block should become a diagram instead of a highlighted code block.

## Flowchart

```mermaid
flowchart TD
    A[Open markdown file] --> B{Contains Mermaid?}
    B -- Yes --> C[Render diagram]
    B -- No --> D[Render normal markdown]
    C --> E[Preview in WebView]
    D --> E
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant App as MarkdownPreviewer
    participant Renderer
    User->>App: Open .md file
    App->>Renderer: render(markdown)
    Renderer-->>App: HTML
    App-->>User: Preview
```

## Class Diagram

```mermaid
classDiagram
    class PreviewDocument {
        +URL fileURL
        +String text
        +reload()
    }
    class MarkdownRenderer {
        +render(markdown, title, baseURL)
    }
    PreviewDocument --> MarkdownRenderer
```

## State Diagram

```mermaid
stateDiagram-v2
    [*] --> Empty
    Empty --> Loaded: open file
    Loaded --> Reloading: file changed
    Reloading --> Loaded: render complete
    Loaded --> Empty: close
```

## Pie Chart

```mermaid
pie title Preview coverage
    "Markdown basics" : 45
    "GFM extensions" : 35
    "Code blocks" : 15
    "Mermaid" : 5
```
