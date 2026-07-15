#!/usr/bin/env swift

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

private enum IconError: LocalizedError {
    case contextCreationFailed
    case imageCreationFailed
    case destinationCreationFailed(URL)
    case pngEncodingFailed(URL)
    case iconutilFailed(Int32)

    var errorDescription: String? {
        switch self {
        case .contextCreationFailed:
            "Unable to create bitmap graphics context"
        case .imageCreationFailed:
            "Unable to create image from bitmap context"
        case .destinationCreationFailed(let url):
            "Unable to create PNG destination at \(url.path)"
        case .pngEncodingFailed(let url):
            "Unable to encode PNG at \(url.path)"
        case .iconutilFailed(let status):
            "iconutil failed with status \(status)"
        }
    }
}

private extension Int {
    var cg: CGFloat { CGFloat(self) }
}

private func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(red: red, green: green, blue: blue, alpha: alpha)
}

private func makeIcon(size: Int) throws -> CGImage {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: size * 4,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        throw IconError.contextCreationFailed
    }

    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    context.interpolationQuality = .high
    context.clear(CGRect(x: 0, y: 0, width: size, height: size))

    let inset = size.cg * 0.07
    let backgroundRect = CGRect(
        x: inset,
        y: inset,
        width: size.cg - inset * 2,
        height: size.cg - inset * 2
    )
    let backgroundPath = CGPath(
        roundedRect: backgroundRect,
        cornerWidth: size.cg * 0.225,
        cornerHeight: size.cg * 0.225,
        transform: nil
    )

    context.saveGState()
    context.addPath(backgroundPath)
    context.clip()

    let gradientColors = [
        color(1.0, 0.46, 0.25),
        color(0.32, 0.36, 0.90)
    ] as CFArray
    guard let gradient = CGGradient(
        colorsSpace: colorSpace,
        colors: gradientColors,
        locations: [0, 1]
    ) else {
        throw IconError.contextCreationFailed
    }

    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: backgroundRect.minX, y: backgroundRect.maxY),
        end: CGPoint(x: backgroundRect.maxX, y: backgroundRect.minY),
        options: []
    )

    let cardRects = [
        CGRect(x: size.cg * 0.205, y: size.cg * 0.335, width: size.cg * 0.59, height: size.cg * 0.45),
        CGRect(x: size.cg * 0.27, y: size.cg * 0.255, width: size.cg * 0.46, height: size.cg * 0.45)
    ]

    for cardRect in cardRects {
        let cardPath = CGPath(
            roundedRect: cardRect,
            cornerWidth: size.cg * 0.068,
            cornerHeight: size.cg * 0.068,
            transform: nil
        )
        context.addPath(cardPath)
        context.setFillColor(color(1, 1, 1, 0.18))
        context.fillPath()

        context.addPath(cardPath)
        context.setStrokeColor(color(1, 1, 1, 0.52))
        context.setLineWidth(max(1, size.cg * 0.01))
        context.strokePath()
    }
    context.restoreGState()

    let font = CTFontCreateWithName("SF Pro Rounded Bold" as CFString, size.cg * 0.51, nil)
    let attributes = [
        kCTFontAttributeName: font,
        kCTForegroundColorAttributeName: color(1, 1, 1)
    ] as CFDictionary
    guard let attributedString = CFAttributedStringCreate(
        kCFAllocatorDefault,
        "S" as CFString,
        attributes
    ) else {
        throw IconError.imageCreationFailed
    }

    let line = CTLineCreateWithAttributedString(attributedString)
    let bounds = CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds, .excludeTypographicLeading])
    let textX = (size.cg - bounds.width) / 2 - bounds.minX
    let textY = size.cg * 0.18 - bounds.minY

    context.saveGState()
    context.setShadow(
        offset: CGSize(width: 0, height: -size.cg * 0.022),
        blur: size.cg * 0.02,
        color: color(0, 0, 0, 0.22)
    )
    context.textPosition = CGPoint(x: textX, y: textY)
    CTLineDraw(line, context)
    context.restoreGState()

    guard let image = context.makeImage() else {
        throw IconError.imageCreationFailed
    }
    return image
}

private func writePNG(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(
        url as CFURL,
        UTType.png.identifier as CFString,
        1,
        nil
    ) else {
        throw IconError.destinationCreationFailed(url)
    }

    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        throw IconError.pngEncodingFailed(url)
    }
}

let arguments = CommandLine.arguments
let outputDirectory = arguments.count > 1
    ? URL(fileURLWithPath: arguments[1])
    : URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconsetURL = outputDirectory.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let icnsURL = outputDirectory.appendingPathComponent("AppIcon.icns")

try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

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
    let destination = iconsetURL.appendingPathComponent(filename)
    try writePNG(makeIcon(size: pixels), to: destination)
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

if process.terminationStatus != 0 {
    throw IconError.iconutilFailed(process.terminationStatus)
}

print(icnsURL.path)
