//
//  AppToast.swift
//  SSC_Lab
//
//  Single toast modifier
//

import SwiftUI

enum AppToastStyle {
    case primary
    case secondary
    case destructive

    var iconName: String {
        switch self {
        case .primary, .secondary: return "checkmark.circle.fill"
        case .destructive: return "trash.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .primary: return Color.appPrimary
        case .secondary: return Color.appSecondary
        case .destructive: return Color.red
        }
    }

    var undoButtonColor: Color {
        switch self {
        case .primary, .secondary: return .white
        case .destructive: return .red
        }
    }
}

private let toastAboveSafeArea: CGFloat = 120
private let toastPillHeight: CGFloat = 50
private let toastHorizontalPadding: CGFloat = 20

struct AppToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    var message: String
    var style: AppToastStyle = .primary
    var autoHideSeconds: Double = 3
    var undoTitle: String? = nil
    var onUndo: (() -> Void)? = nil

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isShowing {
                    ToastOverlayContent(
                        isShowing: $isShowing,
                        message: message,
                        style: style,
                        autoHideSeconds: autoHideSeconds,
                        undoTitle: undoTitle,
                        onUndo: onUndo
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
    }
}

private struct ToastOverlayContent: View {
    @Binding var isShowing: Bool
    var message: String
    var style: AppToastStyle
    var autoHideSeconds: Double
    var undoTitle: String?
    var onUndo: (() -> Void)?

    @AccessibilityFocusState private var isToastFocused: Bool
    @State private var hideTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer(minLength: 0)
                pillContent
                    .padding(.bottom, geo.safeAreaInsets.bottom + toastAboveSafeArea)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppSpacing.block)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear {
            scheduleAutoHide()
            

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isToastFocused = true
            }
        }
        .onChange(of: message) { _, _ in
            isToastFocused = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                isToastFocused = true
            }
        }
        .onDisappear {
            hideTask?.cancel()
            hideTask = nil
        }
    }

    private func dismissWithAnimation() {
        hideTask?.cancel()
        hideTask = nil
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            isShowing = false
        }
    }

    private func scheduleAutoHide() {
        hideTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(autoHideSeconds * 1_000_000_000))
            if !Task.isCancelled { dismissWithAnimation() }
        }
    }

    private var pillContent: some View {
        HStack(spacing: AppSpacing.small) {
            HStack(spacing: AppSpacing.tight) {
                Image(systemName: style.iconName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(style.iconColor)
                    .accessibilityHidden(true)
                Text(message)
                    .font(.appSubHeadline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
            if let onUndo {
                Button {
                    onUndo()
                    dismissWithAnimation()
                } label: {
                    Text(undoTitle ?? "Undo")
                        .font(.appSubHeadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(style.undoButtonColor)
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, toastHorizontalPadding)
        .frame(height: toastPillHeight)
        .background(Capsule().fill(Color.appFont))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
        .contentShape(Capsule())
        .onTapGesture { dismissWithAnimation() }
 
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(onUndo != nil ? "\(message), double tap to undo." : message)
        .accessibilityAddTraits(onUndo != nil ? .isButton : .isStaticText)
        .accessibilityFocused($isToastFocused)
        .accessibilityAction {
            onUndo?()
        }
    }
}

extension View {
    func appToast(
        isShowing: Binding<Bool>,
        message: String,
        style: AppToastStyle = .primary,
        autoHideSeconds: Double = 3,
        undoTitle: String? = nil,
        onUndo: (() -> Void)? = nil
    ) -> some View {
        modifier(AppToastModifier(
            isShowing: isShowing,
            message: message,
            style: style,
            autoHideSeconds: autoHideSeconds,
            undoTitle: undoTitle,
            onUndo: onUndo
        ))
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.appBg.ignoresSafeArea()
        Text("Content")
            .appToast(isShowing: .constant(true), message: "Lab's now Active! 🔥")
    }
}
