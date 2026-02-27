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
        "target": "Target", "heart.fill": "Heart", "star.fill": "Star", "flame.fill": "Flame",
        "bolt.fill": "Bolt", "drop.fill": "Drop", "leaf.fill": "Leaf", "sun.max.fill": "Sun", "moon.stars.fill": "Moon and stars",
        "sparkles": "Sparkles", "brain.head.profile": "Brain", "figure.run": "Running", "figure.walk": "Walking",
        "figure.mind.and.body": "Mind and body", "bed.double.fill": "Bed", "book.fill": "Book", "pencil.circle.fill": "Pencil",
        "graduationcap.fill": "Graduation cap", "lightbulb.fill": "Light bulb", "trophy.fill": "Trophy", "medal.fill": "Medal",
        "flag.fill": "Flag", "checklist": "Checklist", "clock.fill": "Clock", "timer": "Timer", "hourglass": "Hourglass",
        "calendar": "Calendar", "house.fill": "House", "cart.fill": "Cart", "bag.fill": "Bag", "creditcard.fill": "Credit card",
        "gift.fill": "Gift", "music.note": "Music", "camera.fill": "Camera", "envelope.fill": "Envelope", "phone.fill": "Phone",
        "pin.fill": "Pin", "location.fill": "Location", "cup.and.saucer.fill": "Cup and saucer", "fork.knife": "Fork and knife",
        "pills.fill": "Pills", "cross.case.fill": "Medical case", "pawprint.fill": "Paw print", "bird.fill": "Bird", "tree.fill": "Tree",
        "paintpalette.fill": "Paint palette", "hand.raised.fingers.spread.fill": "Hand raised", "swift": "Swift logo",
        "video.fill": "Video", "play.square.stack.fill": "Animations", "sparkle.magnifyingglass": "New interest",
        "bookmark.fill": "Bookmark", "hands.and.sparkles.fill": "One time win", "apple.logo": "Apple logo",
        "cube.transparent.fill": "3D Cube", "photo.artframe": "Art frame", "pencil.line": "Sketching",
        "mouth.fill": "Food", "handbag.fill": "Crochet and crafts", "sunrise.fill": "Sunrise",
        "triangle.bottomhalf.filled": "Onigiri", "suit.heart.fill": "Love", "birthday.cake.fill": "Cake",
        "chart.bar.xaxis.ascending": "Trading", "square.stack.3d.up.fill": "Paper tower",
        "computermouse.fill": "Mouse drawing", "takeoutbag.and.cup.and.straw.fill": "Coffee and berry", "fish.fill": "Aquarium",
        "macbook.and.iphone": "Development Devices", "wifi": "Wifi", "keyboard": "Keyboard", "gamecontroller.fill": "Gaming",
        "headphones": "Focus music", "briefcase.fill": "Business", "shippingbox.fill": "Catchi Shipping",
        "paintbrush.pointed.fill": "Anime Drawing", "wand.and.stars": "Magic", "popcorn.fill": "Anime watch session", "paperplane.fill": "Idea sent",
        "books.vertical.fill": "Library", "newspaper.fill": "News", "dumbbell.fill": "Workout", "basketball.fill": "Sports",
        "power.circle.fill": "Power", "zzz": "Rest", "sparkle": "Idea", "play.fill": "Play",
        "exclamationmark.triangle.fill": "Warning", "heart.badge.bolt.fill": "Health energy", "suit.club.fill": "Card games",
        "flag.pattern.checkered": "Finish line", "wand.and.sparkles": "Creative magic", "puzzlepiece.fill": "Puzzle games",
        "fireworks": "Celebration", "party.popper.fill": "Party", "teddybear.fill": "Hobbies", "airplane.ticket.fill": "Travel",
        "hare.fill": "Speed", "staroflife.fill": "Medical", "sunglasses.fill": "Summer vibes", "mug": "Coffee mug"
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

        "star.fill", "paintpalette.fill", "paintbrush.pointed.fill", "pencil.line", "pencil.circle.fill", "photo.artframe", "wand.and.stars", "wand.and.sparkles", "sparkles", "sparkle", "fireworks", "party.popper.fill", "swift", "apple.logo", "macbook.and.iphone", "keyboard", "wifi", "cpu", "bolt.fill","cube.transparent.fill", "play.square.stack.fill", "graduationcap.fill", "lightbulb.fill", "brain.head.profile", "briefcase.fill", "shippingbox.fill", "chart.bar.xaxis.ascending", "target", "checklist","calendar", "clock.fill", "timer", "hourglass", "paperplane.fill", "envelope.fill", "cup.and.saucer.fill", "mug", "takeoutbag.and.cup.and.straw.fill", "fork.knife", "mouth.fill", "birthday.cake.fill", "triangle.bottomhalf.filled", "cart.fill", "bag.fill", "handbag.fill",  "book.fill", "books.vertical.fill", "newspaper.fill", "bookmark.fill", "gamecontroller.fill","puzzlepiece.fill", "suit.club.fill", "video.fill", "camera.fill", "music.note", "headphones", "popcorn.fill", "figure.run", "figure.walk", "figure.mind.and.body", "dumbbell.fill", "basketball.fill","trophy.fill", "medal.fill", "flag.pattern.checkered", "heart.fill", "heart.badge.bolt.fill", "pills.fill", "staroflife.fill", "airplane.ticket.fill", "location.fill", "pin.fill", "mountain.2.fill", "sun.max.fill", "sunrise.fill", "moon.stars.fill", "leaf.fill", "tree.fill", "fish.fill", "pawprint.fill", "hare.fill", "teddybear.fill", "house.fill", "bed.double.fill", "zzz", "power.circle.fill", "sunglasses.fill", "gift.fill", "flag.fill", "exclamationmark.triangle.fill"
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
            ZStack {
                Text("Choose Icon")
                    .font(.appSubHeadline)
                    .foregroundStyle(Color.appFont)
                    .accessibilityAddTraits(.isHeader)
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack {
                    Spacer()
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
