//
//  RootPopUpState.swift
//  SSC_Lab
//
//  Unified root-level pop-up state so overlays (dimmed background + centered card)
//  cover the tab bar. All root pop-ups use: centered card, scale+opacity transition,
//  tap-outside to dismiss. Add Collection is the first; Quick Log and others can follow.
//

import SwiftUI

// MARK: - Add Collection pop-up data

@Observable
final class AddCollectionPopUpData: Equatable {
    var name: String
    let isDuplicate: (String) -> Bool
    let onCreate: (String) -> Void

    init(name: String = "", isDuplicate: @escaping (String) -> Bool, onCreate: @escaping (String) -> Void) {
        self.name = name
        self.isDuplicate = isDuplicate
        self.onCreate = onCreate
    }

    static func == (lhs: AddCollectionPopUpData, rhs: AddCollectionPopUpData) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: - Root pop-up type

enum RootPopUpType: Equatable {
    case none
    case addCollection(AddCollectionPopUpData)
}

// MARK: - Root pop-up state

@MainActor
@Observable
final class RootPopUpState {
    var activePopUp: RootPopUpType = .none

    var hasActivePopUp: Bool {
        if case .none = activePopUp { return false }
        return true
    }

    func dismiss() {
        activePopUp = .none
    }

    func presentAddCollection(_ data: AddCollectionPopUpData) {
        activePopUp = .addCollection(data)
    }
}

// MARK: - Environment

private struct RootPopUpStateKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: RootPopUpState? = nil
}

extension EnvironmentValues {
    var rootPopUpState: RootPopUpState? {
        get { self[RootPopUpStateKey.self] }
        set { self[RootPopUpStateKey.self] = newValue }
    }
}

// MARK: - Add Collection card (same design as before; used at root in MainTabView)

struct AddCollectionCardView: View {
    @Bindable var data: AddCollectionPopUpData
    var onDismiss: () -> Void

    var body: some View {
        let trimmed = data.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEmpty = trimmed.isEmpty
        let isDuplicate = !isEmpty && data.isDuplicate(data.name)
        let canCreate = !isEmpty && !isDuplicate

        VStack(spacing: 0) {
            Text("New Collection")
                .font(.appHeroSmall)
                .foregroundStyle(Color.appFont)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            TextField("Collection Name", text: $data.name)
                .font(.appBody)
                .foregroundStyle(Color.appFont)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, AppSpacing.section)
                .padding(.top, AppSpacing.section)
            if isDuplicate {
                Text("A collection with this name already exists.")
                    .font(.appBodySmall)
                    .foregroundStyle(Color.appAlert)
                    .multilineTextAlignment(.center)
                    .padding(.top, AppSpacing.tight)
                    .padding(.horizontal, AppSpacing.section)
            }
            HStack(spacing: AppSpacing.small) {
                AppButton(title: "Cancel", style: .secondary, action: onDismiss)
                AppButton(title: "Create", style: .primary) {
                    let name = data.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty, !data.isDuplicate(name) else { return }
                    data.onCreate(name)
                }
                .disabled(!canCreate)
            }
            .padding(.top, AppSpacing.block)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appSecondary.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.xLarge)
        .contentShape(Rectangle())
        .onTapGesture { }
    }
}
