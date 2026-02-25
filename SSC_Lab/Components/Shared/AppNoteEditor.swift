//
//  AppNoteEditor.swift
//  SSC_Lab
//
//

import SwiftUI

struct AppNoteEditor: View {
    @Binding var text: String
    var placeholder: String

    private let minHeight: CGFloat = 150
    private let cornerRadius: CGFloat = 16
    private let dividerPadding: CGFloat = 7

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Note")
                .font(.appSubHeadline)
                .foregroundStyle(Color.appFont)

            Divider()
                .background(Color.appFont)
                .frame(height: 1)
                .padding(.bottom, dividerPadding)

            editorBox
        }
    }

    private var editorBox: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.appSecondary, lineWidth: 1)
                )

            if text.isEmpty {
                Text(placeholder)
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondary)
                    .padding(.leading, AppSpacing.card)
                    .padding(.top, AppSpacing.section)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            TextEditor(text: $text)
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .accessibilityLabel("Note")
                .padding(AppSpacing.small)
                .padding(.horizontal, 4)
                .padding(.trailing, 28)
                .padding(.bottom, AppSpacing.small)
                .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: .infinity, alignment: .topLeading)

            Image(systemName: "line.3.horizontal")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.appFont.opacity(0.2))
                .rotationEffect(.degrees(-45))
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Preview

#Preview("AppNoteEditor") {
    struct PreviewHost: View {
        @State private var text = ""
        var body: some View {
            AppNoteEditor(text: $text, placeholder: "Add a note...")
                .padding()
                .background(Color.appBg)
        }
    }
    return PreviewHost()
}
