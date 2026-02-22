//
//  UIImage+Resize.swift
//  SSC_Lab
//
//  Resize and compress images for storage so the SwiftData store stays lean.
//

import UIKit

extension UIImage {
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
