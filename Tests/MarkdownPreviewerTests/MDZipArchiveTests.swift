import Foundation
import XCTest
import ZIPFoundation
@testable import MarkdownPreviewer

final class MDZipArchiveTests: XCTestCase {
    func testLoadsManifestEntryPointAndPackagedFiles() throws {
        let archiveURL = try makeArchive(entries: [
            "manifest.json": Data(#"{"spec":{"name":"mdzip-spec","version":"1.1.0"},"title":"Guide","mode":"project","entryPoint":"guide/start.md"}"#.utf8),
            "guide/start.md": Data("# Start\n\n[Next](next.md)\n\n![Logo](../images/logo.png)".utf8),
            "guide/next.md": Data("# Next".utf8),
            "images/logo.png": Data([0x89, 0x50, 0x4E, 0x47])
        ])
        defer { try? FileManager.default.removeItem(at: archiveURL) }

        let archive = try MDZipArchiveLoader().load(archiveURL)
        defer { archive.removeExtractedFiles() }

        XCTAssertEqual(archive.title, "Guide")
        XCTAssertEqual(archive.entryPoint, "guide/start.md")
        XCTAssertEqual(archive.markdownPaths, ["guide/next.md", "guide/start.md"])
        XCTAssertEqual(
            try String(contentsOf: archive.markdownURL(for: archive.entryPoint)!, encoding: .utf8),
            "# Start\n\n[Next](next.md)\n\n![Logo](../images/logo.png)"
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: archive.extractionRoot.appendingPathComponent("images/logo.png").path
            )
        )
    }

    func testUsesIndexBeforeAnotherRootMarkdownFile() throws {
        let archiveURL = try makeArchive(entries: [
            "index.md": Data("# Home".utf8),
            "other.md": Data("# Other".utf8)
        ])
        defer { try? FileManager.default.removeItem(at: archiveURL) }

        let archive = try MDZipArchiveLoader().load(archiveURL)
        defer { archive.removeExtractedFiles() }

        XCTAssertEqual(archive.entryPoint, "index.md")
    }

    func testRejectsAmbiguousEntryPoint() throws {
        let archiveURL = try makeArchive(entries: [
            "first.md": Data("# First".utf8),
            "second.md": Data("# Second".utf8)
        ])
        defer { try? FileManager.default.removeItem(at: archiveURL) }

        XCTAssertThrowsError(try MDZipArchiveLoader().load(archiveURL)) { error in
            guard case MDZipError.unresolvedEntryPoint = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testRejectsUnsafeArchivePath() throws {
        let archiveURL = try makeArchive(entries: [
            "index.md": Data("# Home".utf8),
            "../outside.txt": Data("unsafe".utf8)
        ])
        defer { try? FileManager.default.removeItem(at: archiveURL) }

        XCTAssertThrowsError(try MDZipArchiveLoader().load(archiveURL)) { error in
            guard case MDZipError.invalidPath("../outside.txt") = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testRejectsUnsupportedModeAndMajorVersion() throws {
        let unsupportedModeURL = try makeArchive(entries: [
            "manifest.json": Data(#"{"spec":{"version":"1.1.0"},"mode":"collection","entryPoint":"index.md"}"#.utf8),
            "index.md": Data("# Home".utf8)
        ])
        defer { try? FileManager.default.removeItem(at: unsupportedModeURL) }

        XCTAssertThrowsError(try MDZipArchiveLoader().load(unsupportedModeURL)) { error in
            guard case MDZipError.unsupportedMode("collection") = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }

        let unsupportedVersionURL = try makeArchive(entries: [
            "manifest.json": Data(#"{"spec":{"version":"2.0.0"},"entryPoint":"index.md"}"#.utf8),
            "index.md": Data("# Home".utf8)
        ])
        defer { try? FileManager.default.removeItem(at: unsupportedVersionURL) }

        XCTAssertThrowsError(try MDZipArchiveLoader().load(unsupportedVersionURL)) { error in
            guard case MDZipError.unsupportedVersion("2.0.0") = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    private func makeArchive(entries: [String: Data]) throws -> URL {
        let archiveURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mdz")
        let archive = try Archive(url: archiveURL, accessMode: .create)

        for (path, data) in entries.sorted(by: { $0.key < $1.key }) {
            try archive.addEntry(
                with: path,
                type: .file,
                uncompressedSize: Int64(data.count)
            ) { position, size in
                let start = Int(position)
                return data.subdata(in: start..<(start + size))
            }
        }

        return archiveURL
    }
}
