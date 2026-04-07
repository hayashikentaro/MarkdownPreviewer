import AppKit
import Foundation
import UniformTypeIdentifiers

final class PreviewDocument: ObservableObject {
    @Published var fileURL: URL?
    @Published var html: String?
    @Published var errorMessage: String?
    @Published private(set) var lastReloadDescription = "Not loaded"

    private let renderer = MarkdownRenderer()
    private var reloadTimer: Timer?
    private var lastModificationDate: Date?

    var baseURL: URL? {
        fileURL?.deletingLastPathComponent()
    }

    func showOpenPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.markdownFile, .plainText, .text]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Choose a Markdown file to preview."

        if panel.runModal() == .OK, let url = panel.url {
            open(url)
        }
    }

    func open(_ url: URL) {
        fileURL = url
        reload()
        startAutoReload()
    }

    func reload() {
        guard let fileURL else { return }

        do {
            let markdown = try String(contentsOf: fileURL, encoding: .utf8)
            html = renderer.render(markdown, title: fileURL.lastPathComponent)
            lastModificationDate = modificationDate(for: fileURL)
            lastReloadDescription = "Reloaded \(Self.timeFormatter.string(from: Date()))"
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startAutoReload() {
        reloadTimer?.invalidate()
        reloadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.reloadIfNeeded()
        }
    }

    private func reloadIfNeeded() {
        guard let fileURL else { return }
        let currentModificationDate = modificationDate(for: fileURL)

        if currentModificationDate != lastModificationDate {
            reload()
        }
    }

    private func modificationDate(for url: URL) -> Date? {
        try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter
    }()
}

private extension UTType {
    static var markdownFile: UTType {
        UTType(filenameExtension: "md") ?? .plainText
    }
}
