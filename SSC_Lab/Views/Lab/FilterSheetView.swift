//
//  FilterSheetView.swift
//  SSC_Lab
//
//

import SwiftUI
import SwiftData
import UIKit

struct FilterSheetView: View {
    let allExperiments: [Experiment]
    @Binding var filterCriteria: FilterCriteria
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedBadges: Set<BadgeType> = []
    
    private let horizontalMargin: CGFloat = 16
    private let sectionSpacing: CGFloat = 30
    private let capsuleSpacing: CGFloat = 12
    
    private var matchingCount: Int {
        let criteria = FilterCriteria(selectedBadges: selectedBadges)
        return allExperiments.filter { criteria.matches($0) }.count
    }
    
    init(allExperiments: [Experiment], filterCriteria: Binding<FilterCriteria>) {
        self.allExperiments = allExperiments
        _filterCriteria = filterCriteria
        _selectedBadges = State(initialValue: filterCriteria.wrappedValue.selectedBadges)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(title: "Filter", leftContent: {
                    Button(action: { 
                        dismiss() 
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.appSecondaryDark)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.appFont.opacity(0.05)))
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                    .accessibilityHint("Double tap to close without applying")
                }, rightContent: {
                    Button(action: {
                        selectedBadges.removeAll()
                    }) {
                        Text("Reset")
                            .font(.appBodySmall)
                            .foregroundStyle(Color.appFont)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedBadges.isEmpty)
                    .opacity(selectedBadges.isEmpty ? 0.5 : 1)
                    .accessibilityLabel("Reset")
                    .accessibilityHint(selectedBadges.isEmpty ? "No filters applied" : "")
                })
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        /// Environment section
                        EmptyView().sectionHeader(
                            title: Constants.Setup.environmentLabel,
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        filterCapsuleRow(
                            options: [
                                (.indoor, "Indoor", Constants.Icons.indoor),
                                (.outdoor, "Outdoor", Constants.Icons.outdoor)
                            ]
                        )
                        .padding(.horizontal, horizontalMargin)
                        
                        /// Tools section
                        EmptyView().sectionHeader(
                            title: Constants.Setup.toolsLabel,
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        filterCapsuleRow(
                            options: [
                                (.tools, Constants.Setup.required, Constants.Icons.tools),
                                (.noTools, Constants.Setup.none, Constants.Icons.toolsNone)
                            ]
                        )
                        .padding(.horizontal, horizontalMargin)
                        
                        /// Timeframe section
                        EmptyView().sectionHeader(
                            title: Constants.Setup.timeframeLabel,
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        filterCapsuleRow(
                            options: [
                                (.timeframe("1D"), "1D", nil),
                                (.timeframe("7D"), "7D", nil),
                                (.timeframe("30D"), "30D", nil),
                                (.timeframe("+30D"), "+30D", nil)
                            ]
                        )
                        .padding(.horizontal, horizontalMargin)
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.bottom, AppSpacing.large)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg.ignoresSafeArea())
                
                /// Floating bottom button
                VStack(spacing: 0) {
                    Button {
                        filterCriteria = FilterCriteria(selectedBadges: selectedBadges)
                        dismiss()
                    } label: {
                        Text("Show \(matchingCount) Experiment\(matchingCount == 1 ? "" : "s")")
                            .font(.appSubHeadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Double tap to apply filters and close")
                    .padding(AppSpacing.card)
                    .background(Color.appBg)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    /// Filter Capsule Row
    private func filterCapsuleRow(options: [(BadgeType, String, String?)]) -> some View {
        FlowLayout(spacing: capsuleSpacing) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let (badgeType, label, iconName) = option
                let isSelected = selectedBadges.contains(badgeType)
                let a11yLabel: String = { if case .timeframe = badgeType { return TimeframeAccessibilityLabel.spoken(for: label) }; return label }()
                
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        if isSelected {
                            selectedBadges.remove(badgeType)
                        } else {
                            selectedBadges.insert(badgeType)
                        }
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack(spacing: 6) {
                        if let iconName = iconName {
                            Group { }.experimentSetupIcon(iconName: iconName, size: 16)
                        }
                        Text(label)
                            .font(.appBodySmall)
                            .lineLimit(1)
                    }
                    .foregroundStyle(isSelected ? .white : Color.appSecondary)
                    .padding(.horizontal, AppSpacing.card)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.appPrimary : Color.white)
                    )
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? Color.appPrimary : Color.appSecondary, lineWidth: isSelected ? 1.5 : 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(a11yLabel)
                .accessibilitySelected(isSelected)
            }
        }
    }
}

/// Collection Filter Sheet     
struct CollectionFilterSheetView: View {
    let allWins: [Win]
    @Binding var filterCriteria: FilterCriteria
    @Binding var sortOrder: CollectionSortOrder
    @Environment(\.dismiss) private var dismiss

    @State private var selectedBadges: Set<BadgeType> = []
    @State private var selectedSortOrder: CollectionSortOrder = .newestFirst

    private let horizontalMargin: CGFloat = 16
    private let sectionSpacing: CGFloat = 30
    private let capsuleSpacing: CGFloat = 12

    private var matchingCount: Int {
        let criteria = FilterCriteria(selectedBadges: selectedBadges)
        return allWins.filter { criteria.matches($0) }.count
    }

    init(allWins: [Win], filterCriteria: Binding<FilterCriteria>, sortOrder: Binding<CollectionSortOrder>) {
        self.allWins = allWins
        _filterCriteria = filterCriteria
        _sortOrder = sortOrder
        _selectedBadges = State(initialValue: filterCriteria.wrappedValue.selectedBadges)
        _selectedSortOrder = State(initialValue: sortOrder.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppHeader(title: "Filter", leftContent: {
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
                    .accessibilityHint("Double tap to close without applying")
                }, rightContent: {
                    Button(action: {
                        selectedBadges.removeAll()
                        selectedSortOrder = .newestFirst
                    }) {
                        Text("Reset")
                            .font(.appBodySmall)
                            .foregroundStyle(Color.appFont)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedBadges.isEmpty && selectedSortOrder == .newestFirst)
                    .opacity((selectedBadges.isEmpty && selectedSortOrder == .newestFirst) ? 0.5 : 1)
                    .accessibilityLabel("Reset")
                    .accessibilityHint((selectedBadges.isEmpty && selectedSortOrder == .newestFirst) ? "No filters applied" : "")
                })

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        /// Environment
                        EmptyView().sectionHeader(
                            title: Constants.Setup.environmentLabel,
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        filterCapsuleRow(options: [
                            (.indoor, "Indoor", Constants.Icons.indoor),
                            (.outdoor, "Outdoor", Constants.Icons.outdoor)
                        ])
                        .padding(.horizontal, horizontalMargin)

                        /// Tools
                        EmptyView().sectionHeader(
                            title: Constants.Setup.toolsLabel,
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        filterCapsuleRow(options: [
                            (.tools, Constants.Setup.required, Constants.Icons.tools),
                            (.noTools, Constants.Setup.none, Constants.Icons.toolsNone)
                        ])
                        .padding(.horizontal, horizontalMargin)

                        /// Timeframe
                        EmptyView().sectionHeader(
                            title: Constants.Setup.timeframeLabel,
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        filterCapsuleRow(options: [
                            (.timeframe("1D"), "1D", nil),
                            (.timeframe("7D"), "7D", nil),
                            (.timeframe("30D"), "30D", nil),
                            (.timeframe("+30D"), "+30D", nil)
                        ])
                        .padding(.horizontal, horizontalMargin)

                        /// Sort by
                        EmptyView().sectionHeader(
                            title: "Sort by",
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        sortRow
                        .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: 100)
                    }
                    .padding(.bottom, AppSpacing.large)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg.ignoresSafeArea())

                VStack(spacing: 0) {
                    Button {
                        filterCriteria = FilterCriteria(selectedBadges: selectedBadges)
                        sortOrder = selectedSortOrder
                        dismiss()
                    } label: {
                        Text("Show \(matchingCount) Win\(matchingCount == 1 ? "" : "s")")
                            .font(.appSubHeadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.appPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Double tap to apply filters and close")
                    .padding(AppSpacing.card)
                    .background(Color.appBg)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private func filterCapsuleRow(options: [(BadgeType, String, String?)]) -> some View {
        FlowLayout(spacing: capsuleSpacing) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let (badgeType, label, iconName) = option
                let isSelected = selectedBadges.contains(badgeType)
                let a11yLabel: String = { if case .timeframe = badgeType { return TimeframeAccessibilityLabel.spoken(for: label) }; return label }()
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        if isSelected { selectedBadges.remove(badgeType) }
                        else { selectedBadges.insert(badgeType) }
                    }
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack(spacing: 6) {
                        if let iconName = iconName {
                            Group { }.experimentSetupIcon(iconName: iconName, size: 16)
                        }
                        Text(label)
                            .font(.appBodySmall)
                            .lineLimit(1)
                    }
                    .foregroundStyle(isSelected ? .white : Color.appSecondary)
                    .padding(.horizontal, AppSpacing.card)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(isSelected ? Color.appPrimary : Color.white))
                    .overlay(Capsule().stroke(isSelected ? Color.appPrimary : Color.appSecondary, lineWidth: isSelected ? 1.5 : 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(a11yLabel)
                .accessibilitySelected(isSelected)
            }
        }
    }

    private var sortRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            ForEach(CollectionSortOrder.allCases, id: \.self) { order in
                Button {
                    selectedSortOrder = order
                    UISelectionFeedbackGenerator().selectionChanged()
                } label: {
                    HStack {
                        Text(order.rawValue)
                            .font(.appBodySmall)
                            .foregroundStyle(Color.appFont)
                        Spacer()
                        if selectedSortOrder == order {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.appPrimary)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(order.rawValue)
                .accessibilitySelected(selectedSortOrder == order)
            }
        }
    }
}

/// Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var frames: [CGRect] = []
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.frames = frames
            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

// MARK: - Preview
#Preview("FilterSheetView") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Experiment.self, configurations: config)
        
        let experiments = [
            Experiment(title: "POTTERY", icon: "hands.and.sparkles.fill", environment: "indoor", tools: "required", timeframe: "7D"),
            Experiment(title: "HIKING", icon: "mountain.2.fill", environment: "outdoor", tools: "none", timeframe: "30D")
        ]
        for exp in experiments {
            container.mainContext.insert(exp)
        }
        
        return FilterSheetView(
            allExperiments: experiments,
            filterCriteria: .constant(FilterCriteria())
        )
        .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
