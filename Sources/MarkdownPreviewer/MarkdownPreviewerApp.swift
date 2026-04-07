import SwiftUI

@main
struct MarkdownPreviewerApp: App {
    @StateObject private var document = PreviewDocument()

    var body: some Scene {
        WindowGroup {
            ContentView(document: document)
                .frame(minWidth: 760, minHeight: 560)
                .onOpenURL { url in
                    document.open(url)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Markdown...") {
                    document.showOpenPanel()
                }
                .keyboardShortcut("o", modifiers: [.command])

                Button("Reload") {
                    document.reload()
                }
                .keyboardShortcut("r", modifiers: [.command])
                .disabled(document.fileURL == nil)
            }
        }
    }
}
