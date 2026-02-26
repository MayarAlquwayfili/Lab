//
//  CollectionCoverCard.swift
//  SSC_Lab
//
//  Gallery cover card: image only.
//

import SwiftUI
import UIKit

struct CollectionCoverCard: View {
    /// Image data of the most recently added Win. Nil → white background.
    let coverImageData: Data?
    
    private let cornerRadius: CGFloat = 16
    private let strokeWidth: CGFloat = 1.5
    
    var body: some View {
            ZStack {
                Color.white
                
                if let data = coverImageData, let uiImage = UIImage(data: data) {
                    Color.clear
                        .overlay(
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        )
                        .clipped()
                }
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.appFont, lineWidth: strokeWidth)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .aspectRatio(1, contentMode: .fit)
        }
    }



#Preview("CollectionCoverCard") {
    CollectionCoverCard(coverImageData: nil)
        .frame(width: 180)
        .padding()
        .background(Color.appBg)
}
