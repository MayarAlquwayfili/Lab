//
//  ExperimentSetupCard.swift
//  SSC_Lab
//
//  Created by yumii on 13/02/2026.
//

import SwiftUI

/// Setup option enums
enum EnvironmentOption: String, CaseIterable {
    case indoor
    case outdoor
    var label: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .indoor: return Constants.Icons.indoor
        case .outdoor: return Constants.Icons.outdoor
        }
    }
}

enum ToolsOption: String, CaseIterable {
    case required
    case none
    var label: String {
        switch self {
        case .required: return Constants.Setup.required
        case .none: return Constants.Setup.none
        }
    }
    var icon: String {
        switch self {
        case .required: return Constants.Icons.tools
        case .none: return Constants.Icons.toolsNone
        }
    }
}

enum TimeframeOption: String, CaseIterable {
    case oneD = "1D"
    case sevenD = "7D"
    case thirtyD = "30D"
    case plusThirtyD = "+30D"
    var label: String { rawValue }
}

enum LogTypeOption: String, CaseIterable {
    case oneTime
    case newInterest
    var label: String {
        switch self {
        case .oneTime: return Constants.Setup.oneTime
        case .newInterest: return Constants.Setup.newInterest
        }
    }
    var icon: String {
        switch self {
        case .oneTime: return Constants.Icons.oneTime
        case .newInterest: return Constants.Icons.newInterest
        }
    }
}

/// Picker used in each setup row
private struct SetupPickerView<Option: Hashable & Equatable>: View {
    @Binding var selection: Option
    var namespace: Namespace.ID
    let options: [Option]
    let label: (Option) -> String
    var accessibilityLabelOverride: ((Option) -> String)? = nil
    let icon: (Option) -> String?

    private let trackHeight: CGFloat = 36
    private let selectionHeight: CGFloat = 28
    private let trackInset: CGFloat = 4
    private let iconSize: CGFloat = 16

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.offset) { _, option in
                let isSelected = selection == option
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selection = option
                    }
                } label: {
                    HStack(spacing: 4) {
                        if let iconName = icon(option) {
                            Group { }.experimentSetupIcon(iconName: iconName, size: iconSize)
                                .accessibilityHidden(true)
                        }
                        Text(label(option))
                            .font(.appBodySmall)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundStyle(isSelected ? Color.appFont : Color.appSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: selectionHeight)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel((accessibilityLabelOverride ?? label)(option))
                .accessibilitySelected(isSelected)
                .background(
                    Group {
                        if isSelected {
                            Capsule()
                                .fill(Color.appPrimary)
                                .matchedGeometryEffect(id: "segment", in: namespace)
                        }
                    }
                )
            }
        }
        .padding(trackInset)
        .frame(maxWidth: .infinity)
        .frame(height: trackHeight)
        .background(Capsule().fill(Color.appShade01))
    }
}

/// ExperimentSetupCard
struct ExperimentSetupCard: View {
    var showLogType: Bool = true
    
    @Binding var environment: EnvironmentOption
    @Binding var tools: ToolsOption
    @Binding var timeframe: TimeframeOption
    @Binding var logType: LogTypeOption
    
    init(
        showLogType: Bool = true,
        environment: Binding<EnvironmentOption> = .constant(.indoor),
        tools: Binding<ToolsOption> = .constant(.required),
        timeframe: Binding<TimeframeOption> = .constant(.oneD),
        logType: Binding<LogTypeOption> = .constant(.oneTime)
    ) {
        self.showLogType = showLogType
        _environment = environment
        _tools = tools
        _timeframe = timeframe
        _logType = logType
    }

    private let cardWidth: CGFloat = 370
    private let rowHeight: CGFloat = 52
    private let cornerRadius: CGFloat = 16
    private let paddingHorizontal: CGFloat = 16
    private let paddingVertical: CGFloat = 8

    private var cardHeight: CGFloat {
        let rowCount = showLogType ? 4 : 3
        return CGFloat(rowCount) * rowHeight + paddingVertical * 2
    }

    var body: some View {
        VStack(spacing: 0) {
            EmptyView()
                .experimentSetupRow(label: Constants.Setup.environmentLabel, pickerWidth: 240, rowHeight: rowHeight) {
                    SetupPickerView(
                        selection: $environment,
                        namespace: namespaceEnv,
                        options: Array(EnvironmentOption.allCases),
                        label: { $0.label },
                        icon: { $0.icon }
                    )
                }
            Divider()
                .background(Color.gray.opacity(0.2))

            EmptyView()
                .experimentSetupRow(label: Constants.Setup.toolsLabel, pickerWidth: 240, rowHeight: rowHeight) {
                    SetupPickerView(
                        selection: $tools,
                        namespace: namespaceTools,
                        options: Array(ToolsOption.allCases),
                        label: { $0.label },
                        icon: { $0.icon }
                    )
                }
            Divider()
                .background(Color.gray.opacity(0.2))

                EmptyView()
                .experimentSetupRow(label: Constants.Setup.timeframeLabel, pickerWidth: 240, rowHeight: rowHeight) {
                    SetupPickerView(
                        selection: $timeframe,
                        namespace: namespaceTimeframe,
                        options: Array(TimeframeOption.allCases),
                        label: { $0.label },
                        accessibilityLabelOverride: { TimeframeAccessibilityLabel.spoken(for: $0.rawValue) },
                        icon: { _ in nil }
                    )
                }

            if showLogType {
                Divider()
                    .background(Color.gray.opacity(0.2))
                EmptyView()
                    .experimentSetupRow(label: Constants.Setup.logTypeLabel, pickerWidth: 240, rowHeight: rowHeight) {
                        SetupPickerView(
                            selection: $logType,
                            namespace: namespaceLogType,
                            options: Array(LogTypeOption.allCases),
                            label: { $0.label },
                            icon: { $0.icon }
                        )
                    }
            }
        }
        .padding(.horizontal, paddingHorizontal)
        .padding(.vertical, paddingVertical)
        .frame(width: cardWidth, height: cardHeight)  
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }

    @Namespace private var namespaceEnv
    @Namespace private var namespaceTools
    @Namespace private var namespaceTimeframe
    @Namespace private var namespaceLogType
}

// MARK: - Previews

#Preview("ExperimentSetupCard – With Log Type") {
    ExperimentSetupCard(showLogType: true)
        .padding()
        .background(Color.appBg)
}

#Preview("ExperimentSetupCard – Without Log Type") {
    ExperimentSetupCard(showLogType: false)
        .padding()
        .background(Color.appBg)
}
