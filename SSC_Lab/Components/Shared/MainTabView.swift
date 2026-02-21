//
//  MainTabView.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI
import SwiftData

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
    @State private var hideTabBar = false
    @State private var globalToast = GlobalToastState()
    @State private var appPopUpState = AppPopUpState()

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home: HomeView()
                case .lab: LabView(hideTabBar: $hideTabBar)
                case .wins: CollectionsGalleryView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !hideTabBar {
                customTabBar
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(.easeInOut(duration: 0.2), value: hideTabBar)
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
            undoTitle: globalToast.undoTitle,
            onUndo: globalToast.onUndo
        )
        .overlay {
            if appPopUpState.isPresented {
                appPopUpOverlay
            }
        }
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
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: appPopUpState.isPresented)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.appShade01)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.appBg)
    }

    private func tabButton(_ tab: Tab) -> some View {
        let isSelected = selectedTab == tab
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
    }
}

#Preview {
    MainTabView()
}
