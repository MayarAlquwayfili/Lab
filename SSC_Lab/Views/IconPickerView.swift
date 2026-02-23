//
//  IconPickerView.swift
//  SSC_Lab
//
//  Curated SF Symbol picker sheet: General, Lab/Science, Food/Drink, Productivity.
//

import SwiftUI

/// Curated SF Symbols (~50–60) for experiments and wins. User taps to select and sheet dismisses.
struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
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
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(IconPickerView.curatedIcons, id: \.self) { name in
                        iconCell(systemName: name)
                    }
                }
                .padding(horizontalMargin)
                .padding(.bottom, 24)
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
        }
        .padding(.horizontal, horizontalMargin)
        .padding(.vertical, 16)
        .background(Color.appBg)
    }

    private func iconCell(systemName: String) -> some View {
        let isSelected = selectedIcon == systemName
        return Button {
            selectedIcon = systemName
            dismiss()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: iconSize))
                .foregroundStyle(isSelected ? Color.appPrimary : Color.secondary)
                .frame(width: iconSize + cellPadding * 2, height: iconSize + cellPadding * 2)
        }
        .buttonStyle(.plain)
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
