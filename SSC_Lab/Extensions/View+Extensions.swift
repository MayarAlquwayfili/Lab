//
//  View+Extensions.swift
//  SSC_Lab
//
//  Created by yumii on 13/02/2026.
//

import SwiftUI
import UIKit

/// Button style that shows no press feedback (no opacity, scale, or color change)
struct NoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

/// Nav toolbar button
extension View {
    func navButton(icon: String, color: Color = .appFont, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.appFont.opacity(0.05)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
    }
}

/// Discard changes alert
extension View {
    func discardAlert(isPresented: Binding<Bool>, onDiscard: @escaping () -> Void) -> some View {
        alert("Unsaved Changes", isPresented: isPresented) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard", role: .destructive, action: onDiscard)
        } message: {
            Text("Are you sure you want to discard your changes? This action cannot be undone.")
        }
    }
}

/// Global popup state
@Observable
final class AppPopUpState {
    var isPresented = false
    var title = ""
    var message = ""
    var primaryButtonTitle = ""
    var secondaryButtonTitle = ""
    var primaryStyle: AppButtonStyle = .primary
    var showCloseButton = true
    var onPrimary: (() -> Void)?
    var onSecondary: (() -> Void)?
    var onDismiss: (() -> Void)?

    func present(
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String,
        primaryStyle: AppButtonStyle,
        showCloseButton: Bool = true,
        onPrimary: @escaping () -> Void,
        onSecondary: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryStyle = primaryStyle
        self.showCloseButton = showCloseButton
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
        self.onDismiss = onDismiss
        isPresented = true
    }

    func dismiss() {
        onDismiss?()
        onDismiss = nil
        onPrimary = nil
        onSecondary = nil
        isPresented = false
    }
}

private struct AppPopUpStateKey: EnvironmentKey {
    static var defaultValue: AppPopUpState? { nil }}

extension EnvironmentValues {
    var appPopUpState: AppPopUpState? {
        get { self[AppPopUpStateKey.self] }
        set { self[AppPopUpStateKey.self] = newValue }
    }
}

/// Global toast state
@Observable
final class GlobalToastState {
    var isShowing = false
    var message = ""
    var style: AppToastStyle = .primary
    var autoHideSeconds: Double = 3
    var undoTitle: String? = nil
    var onUndo: (() -> Void)? = nil

    func show(_ message: String, style: AppToastStyle = .primary, autoHideSeconds: Double? = nil, undoTitle: String? = nil, onUndo: (() -> Void)? = nil) {
        self.message = message
        self.style = style
        self.autoHideSeconds = autoHideSeconds ?? 3
        self.undoTitle = undoTitle
        self.onUndo = onUndo
        self.isShowing = true
        switch style {
        case .destructive:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .primary, .secondary:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func clearUndo() {
        undoTitle = nil
        onUndo = nil
    }

    /// Shows "Lab Switched! " with Undo or "Lab's now Active! "
    func showActivationToast(previous: Experiment?, undoRevert: @escaping (Experiment) -> Void) {
        if let p = previous {
            show("Lab Switched!", undoTitle: "Undo", onUndo: { undoRevert(p) })
        } else {
            show("Lab's now Active!")
        }
    }
}

private struct GlobalToastStateKey: EnvironmentKey {
    static var defaultValue: GlobalToastState? { nil }
}

extension EnvironmentValues {
    var globalToastState: GlobalToastState? {
        get { self[GlobalToastStateKey.self] }
        set { self[GlobalToastStateKey.self] = newValue }
    }
}

/// Optional binding to hide the main tab bar
private struct HideTabBarBindingKey: EnvironmentKey {
    static var defaultValue: Binding<Bool>? { nil }
}

extension EnvironmentValues {
    var hideTabBarBinding: Binding<Bool>? {
        get { self[HideTabBarBindingKey.self] }
        set { self[HideTabBarBindingKey.self] = newValue }
    }
}

/// Optional binding to the main tab selection
private struct SelectedTabBindingKey: EnvironmentKey {
    static var defaultValue: Binding<Tab>? { nil }
}

extension EnvironmentValues {
    var selectedTabBinding: Binding<Tab>? {
        get { self[SelectedTabBindingKey.self] }
        set { self[SelectedTabBindingKey.self] = newValue }
    }
}

/// Syncs local isPresented to global state when useGlobal and available
private struct GlobalPopUpSyncView: View {
    @Binding var isPresented: Bool
    var title: String
    var message: String
    var primaryButtonTitle: String
    var secondaryButtonTitle: String
    var primaryStyle: AppButtonStyle
    var useGlobal: Bool
    var showCloseButton: Bool
    var onPrimary: () -> Void
    var onSecondary: () -> Void
    @Environment(\.appPopUpState) private var popupState

    var body: some View {
        Group {
            if useGlobal, let state = popupState {
                Color.clear
                    .onAppear {
                        if isPresented {
                            state.present(
                                title: title,
                                message: message,
                                primaryButtonTitle: primaryButtonTitle,
                                secondaryButtonTitle: secondaryButtonTitle,
                                primaryStyle: primaryStyle,
                                showCloseButton: showCloseButton,
                                onPrimary: onPrimary,
                                onSecondary: onSecondary,
                                onDismiss: { isPresented = false }
                            )
                        }
                    }
                    .onChange(of: isPresented) { _, newValue in
                        if newValue {
                            state.present(
                                title: title,
                                message: message,
                                primaryButtonTitle: primaryButtonTitle,
                                secondaryButtonTitle: secondaryButtonTitle,
                                primaryStyle: primaryStyle,
                                showCloseButton: showCloseButton,
                                onPrimary: onPrimary,
                                onSecondary: onSecondary,
                                onDismiss: { isPresented = false }
                            )
                        }
                    }
            } else if isPresented {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea(.all)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if showCloseButton {
                                isPresented = false
                            }
                        }
                    AppPopUp(
                        title: title,
                        message: message,
                        primaryButtonTitle: primaryButtonTitle,
                        secondaryButtonTitle: secondaryButtonTitle,
                        primaryStyle: primaryStyle,
                        onClose: showCloseButton ? { isPresented = false } : nil,
                        onPrimary: onPrimary,
                        onSecondary: onSecondary
                    )
                }
                .makeAccessibilityModal(if: true)
            }
        }
    }
}

// Custom popup
extension View {
    func showPopUp(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String,
        primaryStyle: AppButtonStyle = .primary,
        useGlobal: Bool = true,
        showCloseButton: Bool = true,
        onPrimary: @escaping () -> Void,
        onSecondary: @escaping () -> Void = {}
    ) -> some View {
        overlay {
            GlobalPopUpSyncView(
                isPresented: isPresented,
                title: title,
                message: message,
                primaryButtonTitle: primaryButtonTitle,
                secondaryButtonTitle: secondaryButtonTitle,
                primaryStyle: primaryStyle,
                useGlobal: useGlobal,
                showCloseButton: showCloseButton,
                onPrimary: onPrimary,
                onSecondary: onSecondary
            )
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }

}

/// Interactive dismiss
@MainActor
private final class SheetDismissDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    var isDisabled: Bool
    var onAttemptToDismiss: (() -> Void)?

    init(isDisabled: Bool, onAttempt: @escaping () -> Void) {
        self.isDisabled = isDisabled
        self.onAttemptToDismiss = onAttempt
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        !isDisabled
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        onAttemptToDismiss?()
    }
}

private struct SheetDismissDelegateView: UIViewRepresentable {
    var isDisabled: Bool
    var onAttempt: () -> Void

    func makeUIView(context: Context) -> UIView { UIView() }

    func updateUIView(_ uiView: UIView, context: Context) {
        let delegate = context.coordinator.delegate
        delegate.isDisabled = isDisabled
        delegate.onAttemptToDismiss = onAttempt
        DispatchQueue.main.async {
            // Walk up to find the presented VC (sheet root); its presentationController is the one we need
            var vc = uiView.parentViewController
            while let v = vc {
                if v.presentationController != nil {
                    v.presentationController?.delegate = delegate
                    break
                }
                vc = v.parent
            }
            if vc == nil {
                uiView.parentViewController?.presentationController?.delegate = delegate
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isDisabled: isDisabled, onAttempt: onAttempt)
    }

    @MainActor
    final class Coordinator {
        let delegate: SheetDismissDelegate
        init(isDisabled: Bool, onAttempt: @escaping () -> Void) {
            self.delegate = SheetDismissDelegate(isDisabled: isDisabled, onAttempt: onAttempt)
        }
    }
}

private extension UIView {
    var parentViewController: UIViewController? {
        var r: UIResponder? = next
        while let next = r {
            if let vc = next as? UIViewController { return vc }
            r = next.next
        }
        return nil
    }
}

extension View {
    /// Disables interactive sheet dismiss when `isDisabled` is true; when user attempts to swipe dismiss, calls `onAttemptToDismiss`.
    func interactiveDismissDisabled(_ isDisabled: Bool, onAttemptToDismiss: @escaping () -> Void) -> some View {
        background(SheetDismissDelegateView(isDisabled: isDisabled, onAttempt: onAttemptToDismiss))
    }
}

/// Dismiss keyboard
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Section header
extension View {
    func sectionHeader(
        title: String,
        topSpacing: CGFloat = 30,
        bottomSpacing: CGFloat = 7,
        horizontalPadding: CGFloat = 16
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.appSubHeadline)
                .foregroundStyle(Color.appFont)
            Divider()
                .background(Color.appFont)
                .frame(height: 1)
        }
        .padding(.top, topSpacing)
        .padding(.bottom, bottomSpacing)
        .padding(.horizontal, horizontalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isHeader)
    }
}

/// Timeframe spoken labels for VoiceOver (e.g. "1D" → "1 Day")
enum TimeframeAccessibilityLabel {
    static func spoken(for raw: String) -> String {
        switch raw {
        case "1D": return "1 Day"
        case "7D": return "7 Days"
        case "30D": return "30 Days"
        case "+30D": return "Over 30 Days"
        default: return raw
        }
    }
}

/// Optional selected trait for segments/pickers (VoiceOver)
extension View {
    @ViewBuilder
    func accessibilitySelected(_ isSelected: Bool) -> some View {
        if isSelected {
            self.accessibilityAddTraits(.isSelected)
        } else {
            self
        }
    }
}

/// Modal trait for popups
extension View {
    @ViewBuilder
    func makeAccessibilityModal(if isPresenting: Bool) -> some View {
        if isPresenting {
            self
                .accessibilityAddTraits(.isModal)
                .accessibilityElement(children: .contain)
        } else {
            self
        }
    }
}

/// Experiment setup icon
extension View {
    @ViewBuilder
    func experimentSetupIcon(iconName: String, size: CGFloat = 16) -> some View {
        if UIImage(named: iconName) != nil {
            Image(iconName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            Image(systemName: iconName)
                .font(.system(size: size, weight: .medium))
        }
    }
}

/// Experiment setup row (label + picker)
extension View {

    func experimentSetupRow<Content: View>(
        label: String,
        pickerWidth: CGFloat = 240,
        rowHeight: CGFloat = 52,
        @ViewBuilder content: () -> Content
    ) -> some View where Content: View {
        HStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(.appBodySmall)
                .foregroundStyle(Color.appFont)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
            Spacer(minLength: 8)
            content()
                .frame(width: pickerWidth)
        }
        .frame(height: rowHeight)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
}

/// Enable Swipe to Back Gesture
extension View {
    func enableSwipeToBack() -> some View {
        self.background(SwipeToBackEnabler())
    }
}

///  Swipe to Back Enabler
private struct SwipeToBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        DispatchQueue.main.async {
           
            if let navigationController = uiViewController.navigationController {
                navigationController.interactivePopGestureRecognizer?.isEnabled = true
                navigationController.interactivePopGestureRecognizer?.delegate = nil
            }
        }
    }
}
