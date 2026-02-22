//
//  DetailCardFrame.swift
//  SSC_Lab
//
//  Reusable frame for Experiment and Win detail cards.
//

import SwiftUI

/// Shared constants for detail cards (ExperimentDetailView & WinDetailView).
enum DetailCardLayout {
    static let cardSize: CGFloat = 370
    static let cardBorderWidth: CGFloat = 3
    static let cardCornerRadius: CGFloat = 16
    static let cardInternalPadding: CGFloat = 8
    /// Padding from header (or top of scroll) to the card.
    static let spacingHeaderToCard: CGFloat = 16
    /// Padding from card to the first content below (notes, date, etc.).
    static let spacingCardToContent: CGFloat = 20
    /// Padding from that content to the action buttons.
    static let spacingContentToButtons: CGFloat = 16
}


struct DetailCardFrame<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(maxWidth: DetailCardLayout.cardSize, maxHeight: DetailCardLayout.cardSize)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: DetailCardLayout.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: DetailCardLayout.cardCornerRadius)
                    .strokeBorder(Color.appFont, lineWidth: DetailCardLayout.cardBorderWidth)
            )
    }
}

// MARK: - Preview

#Preview("DetailCardFrame") {
    DetailCardFrame {
        ZStack {
            RoundedRectangle(cornerRadius: DetailCardLayout.cardCornerRadius)
                .fill(Color.white)
            Text("Card")
                .font(.largeTitle)
        }
    }
    .padding()
    .background(Color.appBg)
}
