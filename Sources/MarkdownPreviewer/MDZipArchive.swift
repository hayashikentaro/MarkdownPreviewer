import Foundation
import ZIPFoundation

struct MDZipArchive {
    let sourceURL: URL
    let extractionRoot: URL
    let title: String?
    let entryPoint: String
    let markdownPaths: [String]

    func markdownURL(for path: String) -> URL? {
        guard markdownPaths.contains(path) else { return nil }
        return extractionRoot.appendingPathComponent(path).standardizedFileURL
    }

    func containsMarkdownURL(_ url: URL) -> Bool {
        guard let relativePath = relativePath(for: url) else { return false }
        return markdownPaths.contains(relativePath)
    }

    func relativePath(for url: URL) -> String? {
        let rootPath = extractionRoot.standardizedFileURL.path
        let candidatePath = url.standardizedFileURL.path
        let prefix = rootPath.hasSuffix("/") ? rootPath : rootPath + "/"
        guard candidatePath.hasPrefix(prefix) else { return nil }
        return String(candidatePath.dropFirst(prefix.count))
    }

    func removeExtractedFiles() {
        try? FileManager.default.removeItem(at: extractionRoot)
    }
}

struct MDZipArchiveLoader {
    static let maximumEntryCount = 10_000
    static let maximumEntrySize: UInt64 = 64 * 1_024 * 1_024
    static let maximumUncompressedSize: UInt64 = 256 * 1_024 * 1_024
    static let maximumCompressionRatio: UInt64 = 1_000

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func load(_ sourceURL: URL) throws -> MDZipArchive {
        let archive: Archive
        do {
            archive = try Archive(url: sourceURL, accessMode: .read)
        } catch {
            throw MDZipError.invalidArchive
        }

        let entries = Array(archive)
        try validate(entries)

        let extractionRoot = fileManager.temporaryDirectory
            .appendingPathComponent("MarkdownPreviewer", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        do {
            try fileManager.createDirectory(at: extractionRoot, withIntermediateDirectories: true)
            try extract(entries, from: archive, to: extractionRoot)
            let manifest = try loadManifest(from: extractionRoot, paths: Set(entries.map(\.path)))
            let markdownPaths = entries
                .filter { $0.type == .file && Self.isMarkdownPath($0.path) }
                .map(\.path)
                .sorted()
            let entryPoint = try resolveEntryPoint(manifest: manifest, markdownPaths: markdownPaths)

            return MDZipArchive(
                sourceURL: sourceURL,
                extractionRoot: extractionRoot,
                title: manifest?.title,
                entryPoint: entryPoint,
                markdownPaths: markdownPaths
            )
        } catch {
            try? fileManager.removeItem(at: extractionRoot)
            throw error
        }
    }

    private func validate(_ entries: [Entry]) throws {
        guard !entries.isEmpty else { throw MDZipError.invalidArchive }
        guard entries.count <= Self.maximumEntryCount else {
            throw MDZipError.archiveTooLarge
        }

        var paths = Set<String>()
        var totalSize: UInt64 = 0

        for entry in entries {
            try validate(path: entry.path)

            guard paths.insert(entry.path).inserted else {
                throw MDZipError.duplicatePath(entry.path)
            }
            guard entry.type != .symlink else {
                throw MDZipError.unsupportedEntry(entry.path)
            }

            let uncompressedSize = entry.uncompressedSize
            let compressedSize = entry.compressedSize
            guard uncompressedSize <= Self.maximumEntrySize else {
                throw MDZipError.archiveTooLarge
            }
            totalSize = try addingWithoutOverflow(totalSize, uncompressedSize)
            guard totalSize <= Self.maximumUncompressedSize else {
                throw MDZipError.archiveTooLarge
            }
            if compressedSize > 0,
               uncompressedSize / compressedSize > Self.maximumCompressionRatio {
                throw MDZipError.suspiciousCompression
            }
        }
    }

    private func validate(path: String) throws {
        guard !path.isEmpty,
              !path.hasPrefix("/"),
              !path.hasPrefix("\\"),
              !path.contains("\\"),
              !path.unicodeScalars.contains(where: { $0.value <= 0x1F || $0.value == 0x7F }),
              path.rangeOfCharacter(from: CharacterSet(charactersIn: ":*?\"<>|")) == nil
        else {
            throw MDZipError.invalidPath(path)
        }

        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        guard !components.contains(".."), !components.contains(".") else {
            throw MDZipError.invalidPath(path)
        }
    }

    private func extract(_ entries: [Entry], from archive: Archive, to root: URL) throws {
        for entry in entries {
            let destination = root.appendingPathComponent(entry.path)
            switch entry.type {
            case .directory:
                try fileManager.createDirectory(at: destination, withIntermediateDirectories: true)
            case .file:
                try fileManager.createDirectory(
                    at: destination.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                _ = try archive.extract(entry, to: destination)
            case .symlink:
                throw MDZipError.unsupportedEntry(entry.path)
            }
        }
    }

    private func loadManifest(from root: URL, paths: Set<String>) throws -> Manifest? {
        guard paths.contains("manifest.json") else { return nil }

        let data = try Data(contentsOf: root.appendingPathComponent("manifest.json"))
        guard String(data: data, encoding: .utf8) != nil else {
            throw MDZipError.invalidManifest
        }

        let manifest: Manifest
        do {
            manifest = try JSONDecoder().decode(Manifest.self, from: data)
        } catch {
            throw MDZipError.invalidManifest
        }

        if let version = manifest.spec?.version,
           let major = Int(version.split(separator: ".").first ?? ""),
           major > 1 {
            throw MDZipError.unsupportedVersion(version)
        }

        if let mode = manifest.mode, mode != "document", mode != "project" {
            throw MDZipError.unsupportedMode(mode)
        }
        return manifest
    }

    private func resolveEntryPoint(manifest: Manifest?, markdownPaths: [String]) throws -> String {
        if let entryPoint = manifest?.entryPoint {
            guard Self.isMarkdownPath(entryPoint), markdownPaths.contains(entryPoint) else {
                throw MDZipError.missingEntryPoint(entryPoint)
            }
            return entryPoint
        }
        if markdownPaths.contains("index.md") {
            return "index.md"
        }

        let rootMarkdownPaths = markdownPaths.filter { !$0.contains("/") }
        guard rootMarkdownPaths.count == 1, let onlyPath = rootMarkdownPaths.first else {
            throw MDZipError.unresolvedEntryPoint
        }
        return onlyPath
    }

    private func addingWithoutOverflow(_ lhs: UInt64, _ rhs: UInt64) throws -> UInt64 {
        let (sum, overflow) = lhs.addingReportingOverflow(rhs)
        guard !overflow else { throw MDZipError.archiveTooLarge }
        return sum
    }

    private static func isMarkdownPath(_ path: String) -> Bool {
        let pathExtension = URL(fileURLWithPath: path).pathExtension.lowercased()
        return pathExtension == "md" || pathExtension == "markdown"
    }
}

private struct Manifest: Decodable {
    struct Specification: Decodable {
        let version: String?
    }

    let spec: Specification?
    let title: String?
    let mode: String?
    let entryPoint: String?
}

enum MDZipError: LocalizedError {
    case invalidArchive
    case invalidPath(String)
    case duplicatePath(String)
    case unsupportedEntry(String)
    case archiveTooLarge
    case suspiciousCompression
    case invalidManifest
    case unsupportedVersion(String)
    case unsupportedMode(String)
    case missingEntryPoint(String)
    case unresolvedEntryPoint

    var errorDescription: String? {
        switch self {
        case .invalidArchive:
            return "The file is not a valid MDZip archive."
        case .invalidPath(let path):
            return "The archive contains an unsafe path: \(path)"
        case .duplicatePath(let path):
            return "The archive contains a duplicate path: \(path)"
        case .unsupportedEntry(let path):
            return "The archive contains an unsupported entry: \(path)"
        case .archiveTooLarge:
            return "The archive is too large to open safely."
        case .suspiciousCompression:
            return "The archive has a suspicious compression ratio."
        case .invalidManifest:
            return "manifest.json is not valid UTF-8 JSON."
        case .unsupportedVersion(let version):
            return "MDZip specification version \(version) is not supported."
        case .unsupportedMode(let mode):
            return "MDZip mode \(mode) is not supported."
        case .missingEntryPoint(let path):
            return "The MDZip entry point does not exist: \(path)"
        case .unresolvedEntryPoint:
            return "The MDZip archive has no unambiguous Markdown entry point."
        }
    }
}
