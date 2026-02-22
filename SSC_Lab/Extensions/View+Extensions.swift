//
//  View+Extensions.swift
//  SSC_Lab
//
//  Created by yumii on 13/02/2026.
//

import SwiftUI
import UIKit

// Nav toolbar button
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

// Discard changes alert
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

// Global popup state
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

// Global toast state
@Observable
final class GlobalToastState {
    var isShowing = false
    var message = ""
    var style: AppToastStyle = .primary
    var undoTitle: String? = nil
    var onUndo: (() -> Void)? = nil

    func show(_ message: String, style: AppToastStyle = .primary, undoTitle: String? = nil, onUndo: (() -> Void)? = nil) {
        self.message = message
        self.style = style
        self.undoTitle = undoTitle
        self.onUndo = onUndo
        self.isShowing = true
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

// Dismiss keyboard
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Section header
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
    }
}

// Experiment setup icon
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

// Experiment setup row (label + picker)
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

// Enable Swipe to Back Gesture
extension View {
    func enableSwipeToBack() -> some View {
        self.background(SwipeToBackEnabler())
    }
}

//  Swipe to Back Enabler
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
