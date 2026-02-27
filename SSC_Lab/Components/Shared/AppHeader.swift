//
//  AppHeader.swift
//  SSC_Lab
//
//

import SwiftUI

private let headerContentHeight: CGFloat = 44
private let horizontalPadding: CGFloat = 16
private let headerButtonSize: CGFloat = 40
private let minTouchTarget: CGFloat = 44
private let fallbackTopPadding: CGFloat = 20

struct AppHeader<Trailing: View>: View {
    let title: String
    let isSubScreen: Bool
    let onBack: (() -> Void)?
    let onClose: (() -> Void)?
    let customSubScreenLeft: (() -> AnyView)?
    let customSubScreenRight: (() -> AnyView)?
    @ViewBuilder let trailing: () -> Trailing

    /// Main screen
    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.title = title
        self.isSubScreen = false
        self.onBack = nil
        self.onClose = nil
        self.customSubScreenLeft = nil
        self.customSubScreenRight = nil
        self.trailing = trailing
    }

    /// Sub-screen with Close (X) button
    init(title: String, onBack: @escaping () -> Void, onClose: @escaping () -> Void) where Trailing == EmptyView {
        self.title = title
        self.isSubScreen = true
        self.onBack = onBack
        self.onClose = onClose
        self.customSubScreenLeft = nil
        self.customSubScreenRight = nil
        self.trailing = { EmptyView() }
    }

    /// Sub-screen with custom right-side content (e.g. "Edit" text button)
    init<Right: View>(title: String, onBack: @escaping () -> Void, @ViewBuilder rightContent: @escaping () -> Right) where Trailing == EmptyView {
        self.title = title
        self.isSubScreen = true
        self.onBack = onBack
        self.onClose = nil
        self.customSubScreenLeft = nil
        self.customSubScreenRight = { AnyView(rightContent()) }
        self.trailing = { EmptyView() }
    }

    /// Sub-screen with custom left and right (e.g. checkmark save)
    init<Left: View, Right: View>(title: String, @ViewBuilder leftContent: @escaping () -> Left, @ViewBuilder rightContent: @escaping () -> Right) where Trailing == EmptyView {
        self.title = title
        self.isSubScreen = true
        self.onBack = nil
        self.onClose = nil
        self.customSubScreenLeft = { AnyView(leftContent()) }
        self.customSubScreenRight = { AnyView(rightContent()) }
        self.trailing = { EmptyView() }
    }

    @State private var safeAreaTop: CGFloat = fallbackTopPadding

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBg
                .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: safeAreaTop)
                Group {
                    if isSubScreen { subContent } else { mainContent }
                }
                .frame(height: headerContentHeight)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: safeAreaTop + headerContentHeight)
        .background(
            GeometryReader { geo in
                Color.clear.preference(key: SafeAreaTopKey.self, value: geo.safeAreaInsets.top)
            }
        )
        .onPreferenceChange(SafeAreaTopKey.self) { value in
            safeAreaTop = value > 0 ? value : fallbackTopPadding
        }
    }

    private var mainContent: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.appHero)
                .foregroundStyle(Color.appFont)
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.horizontal, horizontalPadding)
    }

    private var subContent: some View {
        HStack(alignment: .center, spacing: 0) {
            Group {
                if let customLeft = customSubScreenLeft {
                    customLeft()
                        .frame(height: headerContentHeight, alignment: .leading)
                } else if let onBack = onBack {
                    headerButton(icon: "chevron.left", color: .appFont, action: onBack)
                        .frame(width: minTouchTarget, height: minTouchTarget, alignment: .leading)
                } else {
                    Spacer()
                        .frame(width: headerButtonSize)
                }
            }
            .frame(width: minTouchTarget + horizontalPadding, alignment: .leading)
            
            /// Center title area
            Text(title)
                .font(.appHeroSmall)
                .foregroundStyle(Color.appFont)
                .lineLimit(1)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            /// Right button area (min 44pt touch target)
            Group {
                if let customRight = customSubScreenRight {
                    customRight()
                        .frame(height: headerContentHeight, alignment: .trailing)
                } else if let onClose = onClose {
                    headerButton(icon: "xmark", color: .appSecondaryDark, action: onClose)
                        .frame(width: minTouchTarget, height: minTouchTarget, alignment: .trailing)
                } else {
                    Spacer()
                        .frame(width: headerButtonSize)
                }
            }
            .frame(minWidth: minTouchTarget + horizontalPadding, alignment: .trailing)
        }
        .padding(.horizontal, horizontalPadding)
    }

    private func headerButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: headerButtonSize, height: headerButtonSize)
                .background(Circle().fill(Color.appFont.opacity(0.05)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .frame(minWidth: minTouchTarget, minHeight: minTouchTarget)
        .contentShape(Rectangle())
    }
}

/// Safe area top
private struct SafeAreaTopKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

/// Main header
extension AppHeader where Trailing == EmptyView {
    init(title: String) {
        self.title = title
        self.isSubScreen = false
        self.onBack = nil
        self.onClose = nil
        self.customSubScreenLeft = nil
        self.customSubScreenRight = nil
        self.trailing = { EmptyView() }
    }
}

// MARK: - Previews

#Preview("Main – title only") {
    AppHeader(title: "WINS ARCHIVE")
        .background(Color.appBg)
}

#Preview("Main – with trailing") {
    AppHeader(title: "My Lab") {
        HStack(spacing: 0) {
            Button { } label: {
                Image(systemName: "dice.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appFont)
                    .frame(width: headerButtonSize, height: headerButtonSize)
                    .background(Circle().fill(Color.appFont.opacity(0.05)))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            Button { } label: {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appFont)
                    .frame(width: headerButtonSize, height: headerButtonSize)
                    .background(Circle().fill(Color.appFont.opacity(0.05)))
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
    .background(Color.appBg)
}

#Preview("Sub – centered title") {
    AppHeader(title: "POTTERY", onBack: { }, onClose: { })
        .background(Color.appBg)
}
