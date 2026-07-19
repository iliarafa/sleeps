// Flatten a headless-Chrome screenshot into an opaque, alpha-free sRGB PNG.
//
// Chrome's --screenshot always writes RGBA (PNG colour type 6); App Store Connect
// rejects app icons carrying an alpha channel. This drops the channel via
// CoreGraphics (CGImageAlphaInfo.noneSkipLast -> PNG colour type 2).
//
// Optionally resizes. Headless Chrome CANNOT rasterise this page below ~512px:
// --window-size is clamped to a ~500px viewport floor (smaller values silently
// produce a CROP of a larger layout, not a smaller render), and
// --force-device-scale-factor is clamped at 0.5. So the 1024 master is rendered
// natively — that is the one the App Store gets — and the 320/180 web assets are
// downscaled from it here with .high interpolation. iOS does the same thing to
// the 1024 on device.
//
// Downscaling is done in CoreGraphics, not `sips` — cf. the warning in HANDOFF.md.
//
//   swift docs/art/flatten-png.swift <in.png> <out.png> [size] [RRGGBB]
//     size: output edge in px; 0 or omitted = keep source size
//
// Not part of any build: project.yml's target sources are Countdown/, Shared/ and
// CountdownWidget/, and CountdownKit/Package.swift globs Sources/CountdownKit.
// docs/ is in neither.

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count >= 3 else {
    FileHandle.standardError.write(Data("usage: flatten-png.swift <in.png> <out.png> [size] [RRGGBB]\n".utf8))
    exit(2)
}
let inURL = URL(fileURLWithPath: args[1])
let outURL = URL(fileURLWithPath: args[2])
let wantSize = args.count > 3 ? (Int(args[3]) ?? 0) : 0
let backdrop = UInt32(args.count > 4 ? args[4] : "FFB800", radix: 16) ?? 0xFFB800

guard let src = CGImageSourceCreateWithURL(inURL as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
    FileHandle.standardError.write(Data("cannot read \(inURL.path)\n".utf8))
    exit(1)
}

let w = wantSize > 0 ? wantSize : img.width
let h = wantSize > 0 ? wantSize : img.height
let resizing = (w != img.width || h != img.height)

guard let ctx = CGContext(data: nil, width: w, height: h,
                          bitsPerComponent: 8, bytesPerRow: 0,
                          space: CGColorSpace(name: CGColorSpace.sRGB)!,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    FileHandle.standardError.write(Data("cannot create context\n".utf8))
    exit(1)
}

ctx.interpolationQuality = resizing ? .high : .none
ctx.setFillColor(CGColor(srgbRed: CGFloat((backdrop >> 16) & 255) / 255,
                         green:  CGFloat((backdrop >>  8) & 255) / 255,
                         blue:   CGFloat( backdrop        & 255) / 255,
                         alpha:  1))
ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))

guard let flat = ctx.makeImage(),
      let dst = CGImageDestinationCreateWithURL(outURL as CFURL,
                                                UTType.png.identifier as CFString, 1, nil) else {
    FileHandle.standardError.write(Data("cannot encode \(outURL.path)\n".utf8))
    exit(1)
}
CGImageDestinationAddImage(dst, flat, nil)
guard CGImageDestinationFinalize(dst) else {
    FileHandle.standardError.write(Data("cannot finalize \(outURL.path)\n".utf8))
    exit(1)
}

let how = resizing ? "resized from \(img.width)x\(img.height), .high" : "1:1"
print("\(outURL.lastPathComponent): \(w)x\(h) [\(how)] alphaInfo=\(flat.alphaInfo.rawValue) (5 = noneSkipLast)")
