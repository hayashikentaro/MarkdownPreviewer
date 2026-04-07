import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @ObservedObject var document: PreviewDocument

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()

            if let html = document.html {
                MarkdownWebView(html: html, baseURL: document.baseURL)
            } else {
                emptyState
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: nil) { providers in
            openDroppedFile(from: providers)
        }
        .alert("Could Not Open File", isPresented: .constant(document.errorMessage != nil)) {
            Button("OK") {
                document.errorMessage = nil
            }
        } message: {
            Text(document.errorMessage ?? "")
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Button("Open...") {
                document.showOpenPanel()
            }

            Button("Reload") {
                document.reload()
            }
            .disabled(document.fileURL == nil)

            if let fileURL = document.fileURL {
                Text(fileURL.lastPathComponent)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                Text(document.lastReloadDescription)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            } else {
                Text("Markdown Previewer")
                    .font(.headline)

                Spacer()
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("Open a Markdown File")
                .font(.title2.weight(.semibold))

            Text("Use Command-O or drag a .md file here to preview it like a document.")
                .foregroundStyle(.secondary)

            Button("Choose File...") {
                document.showOpenPanel()
            }
            .keyboardShortcut(.defaultAction)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func openDroppedFile(from providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            return false
        }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard
                let data = item as? Data,
                let url = URL(dataRepresentation: data, relativeTo: nil)
            else {
                return
            }

            DispatchQueue.main.async {
                document.open(url)
            }
        }

        return true
    }
}
