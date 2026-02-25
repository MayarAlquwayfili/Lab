//
//  MainTabView.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

/// Shared state for the randomizer overlay so it can be shown at root level (covering the tab bar).
@MainActor
@Observable
final class RandomizerState {
    var isPresented = false
    var experiment: Experiment?
    var onLetsDoIt: (() -> Void)?
    var onSpinAgain: (() -> Void)?

    func present(experiment: Experiment?, onLetsDoIt: @escaping () -> Void, onSpinAgain: @escaping () -> Void) {
        self.experiment = experiment
        self.onLetsDoIt = onLetsDoIt
        self.onSpinAgain = onSpinAgain
        isPresented = true
    }

    func dismiss() {
        isPresented = false
        experiment = nil
        onLetsDoIt = nil
        onSpinAgain = nil
    }
}

private struct RandomizerStateKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: RandomizerState? = nil
}
extension EnvironmentValues {
    var randomizerState: RandomizerState? {
        get { self[RandomizerStateKey.self] }
        set { self[RandomizerStateKey.self] = newValue }
    }
}

enum Tab: Int, CaseIterable {
    case home = 0
    case lab
    case wins
    case settings

    var label: String {
        switch self {
        case .home: return Constants.AppTabBar.homeLabel
        case .lab: return Constants.AppTabBar.labLabel
        case .wins: return Constants.AppTabBar.winsLabel
        case .settings: return Constants.AppTabBar.settingsLabel
        }
    }

    var icon: String {
        switch self {
        case .home: return Constants.AppTabBar.homeIcon
        case .lab: return Constants.AppTabBar.labIcon
        case .wins: return Constants.AppTabBar.winsIcon
        case .settings: return Constants.AppTabBar.settingsIcon
        }
    }
}

struct MainTabView: View {
    @Namespace private var animation
    @State private var selectedTab: Tab = .lab
    @AccessibilityFocusState private var randomizerFirstButtonFocused: Bool
    @AccessibilityFocusState private var resultFocused: Bool
    @State private var hideTabBar = false
    @State private var globalToast = GlobalToastState()
    @State private var appPopUpState = AppPopUpState()
    @State private var randomizerState = RandomizerState()
    @State private var rootPopUpState = RootPopUpState()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content + tab bar
            ZStack {
                Color.appBg.ignoresSafeArea(.all, edges: .bottom)

                Group {
                    switch selectedTab {
                    case .home: NavigationStack { HomeView() }
                    case .lab: NavigationStack { LabView(hideTabBar: $hideTabBar) }
                    case .wins: NavigationStack { CollectionsGalleryView() }
                    case .settings: NavigationStack { SettingsView() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg.ignoresSafeArea(.all, edges: .bottom))
                .containerBackground(Color.appBg, for: .navigation)
                .ignoresSafeArea(.all, edges: .bottom)
                .toolbar(hideTabBar ? .hidden : .automatic, for: .tabBar)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .bottom)
            .environment(\.hideTabBarBinding, $hideTabBar)
            .environment(\.selectedTabBinding, $selectedTab)
            .environment(\.randomizerState, randomizerState)
            .environment(\.rootPopUpState, rootPopUpState)
            .accessibilityHidden(rootPopUpState.hasActivePopUp || randomizerState.isPresented || appPopUpState.isPresented)

            if !hideTabBar {
                customTabBar
            }

            // Root pop-ups
            if rootPopUpState.hasActivePopUp {
                rootPopUpOverlay
            }

            // Randomizer overlay
            if randomizerState.isPresented {
                randomizerOverlay
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea(.all, edges: .bottom)
        .environment(\.appPopUpState, appPopUpState)
        .environment(\.globalToastState, globalToast)
        .appToast(
            isShowing: Binding(
                get: { globalToast.isShowing },
                set: { new in
                    globalToast.isShowing = new
                    if !new { globalToast.clearUndo() }
                }
            ),
            message: globalToast.message,
            style: globalToast.style,
            autoHideSeconds: globalToast.autoHideSeconds,
            undoTitle: globalToast.undoTitle,
            onUndo: globalToast.onUndo
        )
        .overlay {
            if appPopUpState.isPresented {
                appPopUpOverlay
            }
        }
    }

    /// Unified root pop-up: dimmed background (covers tab bar), tap-outside to dismiss, centered card with scale+opacity transition.
    private var rootPopUpOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture { rootPopUpState.dismiss() }

            switch rootPopUpState.activePopUp {
            case .none:
                EmptyView()
            case .addCollection(let data):
                AddCollectionCardView(data: data, onDismiss: { rootPopUpState.dismiss() })
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: rootPopUpState.activePopUp)
    }

    private var randomizerOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture { randomizerState.dismiss() }

            VStack(spacing: 0) {
                Spacer().frame(height: AppSpacing.xLarge)
                Text(randomizerState.experiment?.title ?? "Next Experiment")
                    .font(.appHeroSmall)
                    .foregroundStyle(Color.appFont)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, AppSpacing.large)
                    .accessibilityFocused($resultFocused)
                    .accessibilityLabel(randomizerState.experiment.map { "Your next experiment is \($0.title)" } ?? "Next Experiment")
                Text("Your Next Experiment")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appSecondaryDark)
                    .multilineTextAlignment(.center)
                    .padding(.top, AppSpacing.small)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
                HStack(spacing: AppSpacing.small) {
                    AppButton(title: "Spin Again", style: .secondary) {
                        randomizerState.onSpinAgain?()
                    }
                    .accessibilityFocused($randomizerFirstButtonFocused)
                    AppButton(title: "Let's Do It!", style: .primary) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        randomizerState.onLetsDoIt?()
                    }
                }
                .padding(.top, AppSpacing.block)
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.block)
            .background(RoundedRectangle(cornerRadius: 26).fill(Color.white))
            .padding(.horizontal, AppSpacing.large)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .topTrailing) {
                Button(action: { randomizerState.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.appSecondary)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(AppSpacing.card)
                .padding(.horizontal, 30)
            }
            .contentShape(Rectangle())
            .onTapGesture { }
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
        .makeAccessibilityModal(if: true)
        .onChange(of: randomizerState.experiment?.id) { _, newId in
            if newId != nil, let exp = randomizerState.experiment {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
                UIAccessibility.post(notification: .screenChanged, argument: exp.title)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    resultFocused = true
                }
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.85), value: randomizerState.isPresented)
        .animation(.easeOut(duration: 0.15), value: randomizerState.experiment?.id)
    }

    private var appPopUpOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture {
                    if appPopUpState.showCloseButton {
                        appPopUpState.dismiss()
                    }
                }
            AppPopUp(
                title: appPopUpState.title,
                message: appPopUpState.message,
                primaryButtonTitle: appPopUpState.primaryButtonTitle,
                secondaryButtonTitle: appPopUpState.secondaryButtonTitle,
                primaryStyle: appPopUpState.primaryStyle,
                onClose: appPopUpState.showCloseButton ? { appPopUpState.dismiss() } : nil,
                onPrimary: {
                    appPopUpState.onPrimary?()
                    appPopUpState.dismiss()
                },
                onSecondary: {
                    appPopUpState.onSecondary?()
                    appPopUpState.dismiss()
                }
            )
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
        .makeAccessibilityModal(if: true)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appPopUpState.isPresented)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .accessibilityHidden(randomizerState.isPresented || rootPopUpState.hasActivePopUp)
        .sensoryFeedback(.selection, trigger: selectedTab)
        .padding(.vertical, AppSpacing.tight)
        .padding(.horizontal, AppSpacing.tight)
        .background(
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.appShade01)
        )
        .padding(.horizontal, AppSpacing.card)
        .padding(.bottom, AppSpacing.tight)
        .padding(.bottom, 38)
        .background(Color.appBg)
    }

    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
        let tabAccessibilityLabel = tab == .wins ? "Wins Collections" : tab.label
        return Button {
            withAnimation(.snappy(duration: 0.3)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: .medium))
                Text(tab.label)
                    .font(.appMicro)
            }
            .foregroundStyle(isSelected ? Color.appPrimary : Color.appSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color.appShade02)
                            .matchedGeometryEffect(id: "TabPill", in: animation)
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tabAccessibilityLabel)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint("Double tap to switch to \(tabAccessibilityLabel)")
    }
}

#Preview {
    MainTabView()
}
