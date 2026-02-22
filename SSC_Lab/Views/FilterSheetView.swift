//
//  FilterSheetView.swift
//  SSC_Lab
//
//

import SwiftUI
import SwiftData

// Filter Criteria
struct FilterCriteria {
    var selectedBadges: Set<BadgeType> = []

    /// Categories used for AND logic: Environment, Tools, Time, Log.
    private static func category(of badge: BadgeType) -> Int {
        switch badge {
        case .indoor, .outdoor: return 0
        case .tools, .noTools: return 1
        case .timeframe: return 2
        case .oneTime, .newInterest: return 3
        case .link: return -1
        }
    }

    /// Returns true if criteria is empty (show all), or if the experiment matches at least one selected badge in every active category (AND logic).
    func matches(_ experiment: Experiment) -> Bool {
        guard !selectedBadges.isEmpty else { return true }

        let expEnv = LabViewModel.topBadge(for: experiment.environment)
        let expTools: BadgeType = experiment.tools.lowercased() == "none" ? .noTools : .tools
        let expTime = BadgeType.timeframe(experiment.timeframe)
        var expLog: BadgeType?
        if let log = experiment.logType, log == "newInterest" { expLog = .newInterest }
        else if experiment.logType != nil { expLog = .oneTime }

        let envSelected = selectedBadges.filter { Self.category(of: $0) == 0 }
        let toolsSelected = selectedBadges.filter { Self.category(of: $0) == 1 }
        let timeSelected = selectedBadges.filter { Self.category(of: $0) == 2 }
        let logSelected = selectedBadges.filter { Self.category(of: $0) == 3 }

        if !envSelected.isEmpty && !envSelected.contains(expEnv) { return false }
        if !toolsSelected.isEmpty && !toolsSelected.contains(expTools) { return false }
        if !timeSelected.isEmpty && !timeSelected.contains(expTime) { return false }
        if !logSelected.isEmpty {
            guard let log = expLog, logSelected.contains(log) else { return false }
        }
        return true
    }

    var isEmpty: Bool {
        selectedBadges.isEmpty
    }

    /// Returns true if criteria is empty, or if the win matches at least one selected badge in every active category (AND logic).
    func matches(_ win: Win) -> Bool {
        guard !selectedBadges.isEmpty else { return true }
        let iconNames = [win.icon1, win.icon2, win.icon3, win.logTypeIcon].compactMap { $0 }
        let winBadges = Set(iconNames.compactMap { BadgeType.from(iconName: $0) })
        let envSelected = selectedBadges.filter { Self.category(of: $0) == 0 }
        let toolsSelected = selectedBadges.filter { Self.category(of: $0) == 1 }
        let timeSelected = selectedBadges.filter { Self.category(of: $0) == 2 }
        let logSelected = selectedBadges.filter { Self.category(of: $0) == 3 }
        if !envSelected.isEmpty && envSelected.intersection(winBadges).isEmpty { return false }
        if !toolsSelected.isEmpty && toolsSelected.intersection(winBadges).isEmpty { return false }
        if !timeSelected.isEmpty && timeSelected.intersection(winBadges).isEmpty { return false }
        if !logSelected.isEmpty && logSelected.intersection(winBadges).isEmpty { return false }
        return true
    }
}


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
                })
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Environment section
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
                        
                        // Tools section
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
                        
                        // Timeframe section
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
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.appBg.ignoresSafeArea())
                
                // Floating bottom button
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
                    .padding(16)
                    .background(Color.appBg)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    // Filter Capsule Row
    private func filterCapsuleRow(options: [(BadgeType, String, String?)]) -> some View {
        FlowLayout(spacing: capsuleSpacing) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let (badgeType, label, iconName) = option
                let isSelected = selectedBadges.contains(badgeType)
                
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        if isSelected {
                            selectedBadges.remove(badgeType)
                        } else {
                            selectedBadges.insert(badgeType)
                        }
                    }
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
                    .padding(.horizontal, 16)
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
            }
        }
    }
}

// MARK: - Collection Filter Sheet (Wins: categories + sort)
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
                })

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Environment
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

                        // Tools
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

                        // Timeframe
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

                        // Sort by
                        EmptyView().sectionHeader(
                            title: "Sort by",
                            topSpacing: sectionSpacing,
                            horizontalPadding: horizontalMargin
                        )
                        sortRow
                        .padding(.horizontal, horizontalMargin)

                        Spacer().frame(height: 100)
                    }
                    .padding(.bottom, 32)
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
                    .padding(16)
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
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        if isSelected { selectedBadges.remove(badgeType) }
                        else { selectedBadges.insert(badgeType) }
                    }
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(isSelected ? Color.appPrimary : Color.white))
                    .overlay(Capsule().stroke(isSelected ? Color.appPrimary : Color.appSecondary, lineWidth: isSelected ? 1.5 : 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var sortRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(CollectionSortOrder.allCases, id: \.self) { order in
                Button {
                    selectedSortOrder = order
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
            }
        }
    }
}

// Flow Layout
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
