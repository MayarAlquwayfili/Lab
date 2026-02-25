//
//  IconPickerView.swift
//  SSC_Lab
//
//   SF Symbol picker sheet
//

import SwiftUI
import UIKit

/// SF Symbol names labels for VoiceOver
enum IconAccessibilityLabel {
    private static let map: [String: String] = [
        "target": "Target", "scope": "Scope", "heart.fill": "Heart", "star.fill": "Star", "flame.fill": "Flame",
        "bolt.fill": "Bolt", "drop.fill": "Drop", "leaf.fill": "Leaf", "sun.max.fill": "Sun", "moon.stars.fill": "Moon and stars",
        "sparkles": "Sparkles", "brain.head.profile": "Brain", "figure.run": "Running", "figure.walk": "Walking",
        "figure.mind.and.body": "Mind and body", "bed.double.fill": "Bed", "book.fill": "Book", "pencil.circle.fill": "Pencil",
        "graduationcap.fill": "Graduation cap", "lightbulb.fill": "Light bulb", "trophy.fill": "Trophy", "medal.fill": "Medal",
        "flag.fill": "Flag", "checklist": "Checklist", "clock.fill": "Clock", "timer": "Timer", "hourglass": "Hourglass",
        "calendar": "Calendar", "house.fill": "House", "cart.fill": "Cart", "bag.fill": "Bag", "creditcard.fill": "Credit card",
        "gift.fill": "Gift", "music.note": "Music", "camera.fill": "Camera", "envelope.fill": "Envelope", "phone.fill": "Phone",
        "pin.fill": "Pin", "location.fill": "Location", "cup.and.saucer.fill": "Cup and saucer", "fork.knife": "Fork and knife",
        "pills.fill": "Pills", "cross.case.fill": "Medical case", "pawprint.fill": "Paw print", "bird.fill": "Bird", "tree.fill": "Tree",
    ]

    static func humanReadable(for symbolName: String) -> String {
        if let label = map[symbolName] { return label }
        return symbolName
            .replacingOccurrences(of: ".fill", with: "")
            .replacingOccurrences(of: ".", with: " ")
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.small), count: 5)
    private let iconSize: CGFloat = 30
    private let cellPadding: CGFloat = 12
    private let horizontalMargin: CGFloat = 20

    private static let curatedIcons: [String] = [
        "target", "scope", "heart.fill", "star.fill", "flame.fill", "bolt.fill",
        "drop.fill", "leaf.fill", "sun.max.fill", "moon.stars.fill", "sparkles",
        "brain.head.profile", "figure.run", "figure.walk", "figure.mind.and.body",
        "bed.double.fill", "book.fill", "pencil.circle.fill", "graduationcap.fill",
        "lightbulb.fill", "trophy.fill", "medal.fill", "flag.fill", "checklist",
        "clock.fill", "timer", "hourglass", "calendar",
        "house.fill", "cart.fill", "bag.fill", "creditcard.fill", "gift.fill",
        "music.note", "camera.fill", "envelope.fill", "phone.fill", "pin.fill",
        "location.fill", "cup.and.saucer.fill", "fork.knife", "pills.fill",
        "cross.case.fill", "pawprint.fill", "bird.fill", "tree.fill",
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppSpacing.small) {
                    ForEach(IconPickerView.curatedIcons, id: \.self) { name in
                        iconCell(systemName: name)
                    }
                }
                .padding(horizontalMargin)
                .padding(.bottom, AppSpacing.block)
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Spacer(minLength: 0)
            Text("Choose Icon")
                .font(.appSubHeadline)
                .foregroundStyle(Color.appFont)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appSecondaryDark)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.appFont.opacity(0.05)))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, horizontalMargin)
        .padding(.vertical, AppSpacing.card)
        .background(Color.appBg)
    }

    private func iconCell(systemName: String) -> some View {
        let isSelected = selectedIcon == systemName
        return Button {
            selectedIcon = systemName
            UISelectionFeedbackGenerator().selectionChanged()
            dismiss()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: iconSize))
                .foregroundStyle(isSelected ? Color.appPrimary : Color.appSecondary)
                .frame(width: iconSize + cellPadding * 2, height: iconSize + cellPadding * 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(IconAccessibilityLabel.humanReadable(for: systemName))
        .accessibilityHint("Double tap to select")
        .accessibilitySelected(isSelected)
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var icon = "star.fill"
        var body: some View {
            IconPickerView(selectedIcon: $icon)
        }
    }
    return PreviewHost()
}
