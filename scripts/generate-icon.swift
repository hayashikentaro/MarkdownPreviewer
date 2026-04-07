#!/usr/bin/env swift

import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputURL = root.appendingPathComponent("Packaging/AppIcon1024.png")
try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)

let size = CGSize(width: 1024, height: 1024)
guard
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ),
    let context = NSGraphicsContext(bitmapImageRep: bitmap)
else {
    throw NSError(domain: "IconGeneration", code: 1)
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = context
defer { NSGraphicsContext.restoreGraphicsState() }

let rect = CGRect(origin: .zero, size: size)
let background = NSGradient(colors: [
    NSColor(calibratedRed: 0.10, green: 0.28, blue: 0.58, alpha: 1.0),
    NSColor(calibratedRed: 0.04, green: 0.11, blue: 0.23, alpha: 1.0)
])!
background.draw(in: rect, angle: -35)

let pageRect = CGRect(x: 162, y: 116, width: 700, height: 792)
let shadow = NSShadow()
shadow.shadowOffset = CGSize(width: 0, height: -28)
shadow.shadowBlurRadius = 38
shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)

let pagePath = NSBezierPath(roundedRect: pageRect, xRadius: 72, yRadius: 72)
NSGraphicsContext.saveGraphicsState()
shadow.set()
NSColor.white.setFill()
pagePath.fill()
NSGraphicsContext.restoreGraphicsState()

NSColor(calibratedWhite: 0.88, alpha: 1.0).setStroke()
pagePath.lineWidth = 5
pagePath.stroke()

let foldPath = NSBezierPath()
foldPath.move(to: CGPoint(x: 710, y: 908))
foldPath.line(to: CGPoint(x: 862, y: 756))
foldPath.line(to: CGPoint(x: 710, y: 756))
foldPath.close()
NSColor(calibratedRed: 0.89, green: 0.94, blue: 1.0, alpha: 1.0).setFill()
foldPath.fill()

NSColor(calibratedWhite: 0.72, alpha: 1.0).setStroke()
foldPath.lineWidth = 4
foldPath.stroke()

let pillRect = CGRect(x: 238, y: 598, width: 548, height: 182)
let pillPath = NSBezierPath(roundedRect: pillRect, xRadius: 42, yRadius: 42)
NSColor(calibratedRed: 0.10, green: 0.18, blue: 0.30, alpha: 1.0).setFill()
pillPath.fill()

let textStyle = NSMutableParagraphStyle()
textStyle.alignment = .center

let markdownAttributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 126, weight: .black),
    .foregroundColor: NSColor.white,
    .paragraphStyle: textStyle
]
let markdownText = "M↓" as NSString
markdownText.draw(
    in: CGRect(x: pillRect.minX, y: pillRect.minY + 22, width: pillRect.width, height: pillRect.height),
    withAttributes: markdownAttributes
)

let lineColor = NSColor(calibratedRed: 0.60, green: 0.68, blue: 0.78, alpha: 1.0)
lineColor.setStroke()
for y in stride(from: 486, through: 286, by: -68) {
    let line = NSBezierPath()
    line.move(to: CGPoint(x: 250, y: y))
    line.line(to: CGPoint(x: 774, y: y))
    line.lineWidth = 24
    line.lineCapStyle = .round
    line.stroke()
}

let shortLine = NSBezierPath()
shortLine.move(to: CGPoint(x: 250, y: 218))
shortLine.line(to: CGPoint(x: 620, y: 218))
shortLine.lineWidth = 24
shortLine.lineCapStyle = .round
shortLine.stroke()

guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
    throw NSError(domain: "IconGeneration", code: 1)
}

try pngData.write(to: outputURL)
print(outputURL.path)
