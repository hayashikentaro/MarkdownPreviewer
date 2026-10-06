import AppKit
import Foundation
import UniformTypeIdentifiers
import WebKit

final class PreviewDocument: ObservableObject {
    @Published var fileURL: URL?
    @Published var html: String?
    @Published var errorMessage: String?
    @Published private(set) var baseURL: URL?
    @Published private(set) var archiveMarkdownPaths: [String] = []
    @Published private(set) var selectedArchivePath: String?
    @Published private(set) var lastReloadDescription = "Not loaded"

    private let renderer = MarkdownRenderer()
    private let archiveLoader = MDZipArchiveLoader()
    private var reloadTimer: Timer?
    private var lastModificationDate: Date?
    private var mdzipArchive: MDZipArchive?
    private weak var printWebView: WKWebView?
    private let printInfo: NSPrintInfo = {
        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.isHorizontallyCentered = true
        return printInfo
    }()

    deinit {
        mdzipArchive?.removeExtractedFiles()
    }

    var canPrint: Bool {
        html != nil
    }

    func showOpenPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.markdownFile, .mdzip, .plainText, .text]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.message = "Choose a Markdown or MDZip file to preview."

        if panel.runModal() == .OK, let url = panel.url {
            open(url)
        }
    }

    func open(_ url: URL) {
        mdzipArchive?.removeExtractedFiles()
        mdzipArchive = nil
        archiveMarkdownPaths = []
        selectedArchivePath = nil
        fileURL = url
        reload()
        startAutoReload()
    }

    func reload() {
        guard let fileURL else { return }

        do {
            if fileURL.pathExtension.lowercased() == "mdz" {
                try reloadMDZip(fileURL)
            } else {
                mdzipArchive?.removeExtractedFiles()
                mdzipArchive = nil
                archiveMarkdownPaths = []
                selectedArchivePath = nil
                try renderMarkdown(at: fileURL, title: fileURL.lastPathComponent)
            }
            lastModificationDate = modificationDate(for: fileURL)
            lastReloadDescription = "Reloaded \(Self.timeFormatter.string(from: Date()))"
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openArchiveMarkdown(_ path: String) {
        guard let archive = mdzipArchive,
              let markdownURL = archive.markdownURL(for: path)
        else { return }

        do {
            try renderMarkdown(
                at: markdownURL,
                title: archive.title ?? archive.sourceURL.lastPathComponent
            )
            selectedArchivePath = path
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openLinkedURL(_ url: URL) -> Bool {
        guard let archive = mdzipArchive, url.isFileURL else { return false }
        guard let relativePath = archive.relativePath(for: url) else {
            return true
        }
        guard archive.containsMarkdownURL(url) else {
            return false
        }

        openArchiveMarkdown(relativePath)
        return true
    }

    func setPrintWebView(_ webView: WKWebView?) {
        printWebView = webView
    }

    func showPageSetup() {
        guard canPrint else { return }
        NSPageLayout().runModal(with: printInfo)
    }

    func printCurrentDocument() {
        guard let printWebView, canPrint else { return }

        let operation = printWebView.printOperation(with: printInfo)
        operation.jobTitle = selectedArchivePath ?? fileURL?.deletingPathExtension().lastPathComponent
        operation.showsPrintPanel = true
        operation.showsProgressPanel = true

        if let window = printWebView.window {
            operation.runModal(
                for: window,
                delegate: nil,
                didRun: nil,
                contextInfo: nil
            )
        } else {
            operation.run()
        }
    }

    private func reloadMDZip(_ fileURL: URL) throws {
        let previousPath = selectedArchivePath
        let loadedArchive = try archiveLoader.load(fileURL)
        mdzipArchive?.removeExtractedFiles()
        mdzipArchive = loadedArchive
        archiveMarkdownPaths = loadedArchive.markdownPaths

        let path = previousPath.flatMap { loadedArchive.markdownPaths.contains($0) ? $0 : nil }
            ?? loadedArchive.entryPoint
        guard let markdownURL = loadedArchive.markdownURL(for: path) else {
            throw MDZipError.missingEntryPoint(path)
        }

        try renderMarkdown(
            at: markdownURL,
            title: loadedArchive.title ?? fileURL.lastPathComponent
        )
        selectedArchivePath = path
    }

    private func renderMarkdown(at markdownURL: URL, title: String) throws {
        let markdown = try String(contentsOf: markdownURL, encoding: .utf8)
        let markdownBaseURL = markdownURL.deletingLastPathComponent()
        baseURL = markdownBaseURL
        html = renderer.render(markdown, title: title, baseURL: markdownBaseURL)
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

    static var mdzip: UTType {
        UTType(importedAs: "org.mdzip.mdz", conformingTo: .zip)
    }
}
