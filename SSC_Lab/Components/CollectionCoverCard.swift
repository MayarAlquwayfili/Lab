//
//  CollectionCoverCard.swift
//  SSC_Lab
//
//  Gallery cover card: image only. Same layout as ExperimentCard (stroke, corners).
//  Title and win count are shown outside/below the card in the gallery.
//

import SwiftUI
import UIKit

struct CollectionCoverCard: View {
    /// Image data of the most recently added Win. Nil → white background.
    let coverImageData: Data?

    // Match ExperimentCard
    private let cornerRadius: CGFloat = 16
    private let strokeWidth: CGFloat = 1.5

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
            Group {
                if let data = coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.white
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.appSecondary, lineWidth: strokeWidth)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview("CollectionCoverCard") {
    CollectionCoverCard(coverImageData: nil)
        .frame(width: 180)
        .padding()
        .background(Color.appBg)
}
