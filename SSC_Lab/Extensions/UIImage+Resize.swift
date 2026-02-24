//
//  UIImage+Resize.swift
//  SSC_Lab
//
//  Resize and compress images for storage so the SwiftData store stays lean.
//  Downsampling for display avoids loading full-resolution images into memory.
//

import UIKit
import ImageIO

extension UIImage {
    /// Decodes image data at reduced size (max 400×400) without loading full bitmap. Use for cards/lists to prevent memory warnings.
    static func downsampled(data: Data, maxDimension: CGFloat = 400) -> UIImage? {
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    /// Resizes so the longest side is at most `maxDimension`, preserving aspect ratio. Returns self if already smaller.
    func resizedForStorage(maxDimension: CGFloat = 1024) -> UIImage? {
        let w = size.width
        let h = size.height
        let longest = max(w, h)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(width: w * scale, height: h * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// JPEG data for SwiftData: resized (longest side ≤ 1024) then compressed. Use before saving.
    func jpegDataForStorage(compressionQuality: CGFloat = 0.8, maxDimension: CGFloat = 1024) -> Data? {
        let resized = resizedForStorage(maxDimension: maxDimension) ?? self
        return resized.jpegData(compressionQuality: compressionQuality)
    }
}
