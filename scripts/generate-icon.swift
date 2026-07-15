#!/usr/bin/env swift

import AppKit
import Foundation

let arguments = CommandLine.arguments
let outputDirectory = arguments.count > 1 ? URL(fileURLWithPath: arguments[1]) : URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = outputDirectory.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let icnsURL = outputDirectory.appendingPathComponent("AppIcon.icns")

try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

func makeIcon(size: Int) throws -> Data {
    let canvasSize = NSSize(width: size, height: size)
    let image = NSImage(size: canvasSize)

    image.lockFocus()
    defer { image.unlockFocus() }

    guard let context = NSGraphicsContext.current?.cgContext else {
        throw NSError(domain: "SwiftUIDemoIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create graphics context"])
    }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)

    let inset = CGFloat(size) * 0.07
    let rect = CGRect(x: inset, y: inset, width: CGFloat(size) - inset * 2, height: CGFloat(size) - inset * 2)
    let radius = CGFloat(size) * 0.225
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)

    context.saveGState()
    context.addPath(path)
    context.clip()

    let colors = [
        NSColor(calibratedRed: 1.0, green: 0.46, blue: 0.25, alpha: 1).cgColor,
        NSColor(calibratedRed: 0.32, green: 0.36, blue: 0.90, alpha: 1).cgColor
    ] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])!
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: rect.minX, y: rect.maxY),
        end: CGPoint(x: rect.maxX, y: rect.minY),
        options: []
    )

    let cardColor = NSColor.white.withAlphaComponent(0.18)
    let borderColor = NSColor.white.withAlphaComponent(0.52)
    let cardRects = [
        CGRect(x: size.cg * 0.205, y: size.cg * 0.335, width: size.cg * 0.59, height: size.cg * 0.45),
        CGRect(x: size.cg * 0.27, y: size.cg * 0.255, width: size.cg * 0.46, height: size.cg * 0.45)
    ]

    for cardRect in cardRects {
        let cardPath = CGPath(roundedRect: cardRect, cornerWidth: size.cg * 0.068, cornerHeight: size.cg * 0.068, transform: nil)
        context.addPath(cardPath)
        context.setFillColor(cardColor.cgColor)
        context.fillPath()
        context.addPath(cardPath)
        context.setStrokeColor(borderColor.cgColor)
        context.setLineWidth(size.cg * 0.01)
        context.strokePath()
    }
    context.restoreGState()

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let font = NSFont.systemFont(ofSize: size.cg * 0.51, weight: .bold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white,
        .paragraphStyle: paragraph,
        .shadow: {
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.22)
            shadow.shadowOffset = NSSize(width: 0, height: -size.cg * 0.022)
            shadow.shadowBlurRadius = size.cg * 0.02
            return shadow
        }()
    ]
    let textRect = CGRect(x: 0, y: size.cg * 0.17, width: size.cg, height: size.cg * 0.62)
    NSAttributedString(string: "S", attributes: attributes).draw(in: textRect)

    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "SwiftUIDemoIcon", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to encode PNG"])
    }
    return png
}

private extension Int {
    var cg: CGFloat { CGFloat(self) }
}

let variants: [(points: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2)
]

for variant in variants {
    let pixels = variant.points * variant.scale
    let suffix = variant.scale == 2 ? "@2x" : ""
    let filename = "icon_\(variant.points)x\(variant.points)\(suffix).png"
    let data = try makeIcon(size: pixels)
    try data.write(to: iconsetURL.appendingPathComponent(filename))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

if process.terminationStatus != 0 {
    throw NSError(domain: "SwiftUIDemoIcon", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "iconutil failed"])
}

print(icnsURL.path)
