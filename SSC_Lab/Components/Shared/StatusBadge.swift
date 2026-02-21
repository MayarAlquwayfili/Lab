//
//  StatusBadge.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI

// Badge Type
enum BadgeType: Hashable {
    case indoor
    case outdoor
    case tools
    case noTools
    case oneTime
    case newInterest
    case link
    case timeframe(String)

    static let iconCases: [BadgeType] = [.indoor, .outdoor, .tools, .noTools, .oneTime, .newInterest, .link]

    var sfSymbolName: String? {
        switch self {
        case .indoor:       return Constants.Icons.indoor
        case .outdoor:     return Constants.Icons.outdoor
        case .tools:       return Constants.Icons.tools
        case .noTools:     return nil
        case .oneTime:     return Constants.Icons.oneTime
        case .newInterest: return Constants.Icons.newInterest
        case .link:        return Constants.Icons.link
        case .timeframe:   return nil
        }
    }

    var imageAssetName: String? {
        if case .noTools = self { return "ic_WithoutTools" }
        return nil
    }

    var isTimeframe: Bool {
        if case .timeframe = self { return true }
        return false
    }
}

// Badge Size
enum BadgeSize {
    case large
    case small

    var circleDimension: CGFloat {
        switch self {
        case .large: return 45
        case .small: return 24
        }
    }

    var iconDimension: CGFloat {
        switch self {
        case .large: return 24
        case .small: return 12
        }
    }

}

// Badge Variant
enum BadgeVariant: Hashable {
    case primary
    case secondary

    var color: Color {
        switch self {
        case .primary:   return .appPrimary
        case .secondary: return .appSecondary
        }
    }
}

// StatusBadge View
struct StatusBadge: View {
    let type: BadgeType
    let size: BadgeSize
    let variant: BadgeVariant

    init(type: BadgeType, size: BadgeSize = .small, variant: BadgeVariant = .primary) {
        self.type = type
        self.size = size
        self.variant = variant
    }

    private var variantColor: Color { variant.color }

    var body: some View {
        ZStack {
            Circle()
                .fill(variantColor)
            contentView
                .frame(width: size.circleDimension, height: size.circleDimension, alignment: .center)
        }
        .frame(width: size.circleDimension, height: size.circleDimension)
    }

    /// Theme font for timeframe label  
    private func timeframeFont(for label: String) -> Font {
        switch size {
        case .large:
            if label == "1D" || label == "7D" { return .appTimeframeL_High }
            if label == "30D" { return .appTimeframeL_Mid }
            if label == "+30D" { return .appTimeframeL_Low }
            return .appTimeframeL_Mid
        case .small:
            if label == "+30D" { return .appTimeframeS_Low }
            return .appTimeframeS_High
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if case .timeframe(let label) = type {
            Text(label)
                .font(timeframeFont(for: label))
                .foregroundStyle(Color.appFont)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } else {
            iconView
                .foregroundStyle(Color.appFont)
                .frame(width: size.iconDimension, height: size.iconDimension, alignment: .center)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        Group {
            if let assetName = type.imageAssetName {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
            } else if let sfName = type.sfSymbolName {
                Image(systemName: sfName)
                    .font(.system(size: size.iconDimension, weight: .medium))
                    .scaleEffect(type == .outdoor ? 0.7 : 1.0)
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Previews
#Preview("StatusBadge – Minimalist (Large + Small)") {
    HStack(spacing: 24) {
        StatusBadge(type: .indoor, size: .large, variant: .primary)
        StatusBadge(type: .indoor, size: .small, variant: .primary)
    }
    .padding(40)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(white: 0.96))
}

#Preview("StatusBadge – Single") {
    StatusBadge(type: .indoor, size: .small, variant: .primary)
        .padding()
        .background(Color.appBg)
}

#Preview("StatusBadge – Icons + Timeframes (all sizes × variants)") {
    let columns = [GridItem(.adaptive(minimum: 56), spacing: 16)]
    let timeframeLabels = ["1D", "7D","30D","+30D"]
    return ScrollView {
        LazyVStack(alignment: .leading, spacing: 28) {
            // Icons section
            VStack(alignment: .leading, spacing: 12) {
                Text("Icons")
                    .font(.headline)
                    .foregroundStyle(Color.appFont)
                ForEach([BadgeVariant.primary, .secondary], id: \.self) { variant in
                    Text(variant == .primary ? "Primary" : "Secondary")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appFont.opacity(0.8))
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(BadgeType.iconCases, id: \.self) { type in
                            VStack(spacing: 6) {
                                StatusBadge(type: type, size: .large, variant: variant)
                                StatusBadge(type: type, size: .small, variant: variant)
                                Text(iconCaseLabel(type))
                                    .font(.caption2)
                                    .foregroundStyle(Color.appFont)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }

            // Timeframes section
            VStack(alignment: .leading, spacing: 12) {
                Text("Timeframes")
                    .font(.headline)
                    .foregroundStyle(Color.appFont)
                ForEach([BadgeVariant.primary, .secondary], id: \.self) { variant in
                    Text(variant == .primary ? "Primary" : "Secondary")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.appFont.opacity(0.8))
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(timeframeLabels, id: \.self) { label in
                            let type = BadgeType.timeframe(label)
                            VStack(spacing: 6) {
                                StatusBadge(type: type, size: .large, variant: variant)
                                StatusBadge(type: type, size: .small, variant: variant)
                                Text(label)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appFont)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBg)
}

private func iconCaseLabel(_ type: BadgeType) -> String {
    switch type {
    case .indoor: return "indoor"
    case .outdoor: return "outdoor"
    case .tools: return "tools"
    case .noTools: return "noTools"
    case .oneTime: return "oneTime"
    case .newInterest: return "newInterest"
    case .link: return "link"
    case .timeframe(let label): return label
    }
}

#Preview("StatusBadge – Compact grid") {
    let iconTypes = BadgeType.iconCases
    let timeframeLabels = ["1D", "7D","30D","+30D"]
    return ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 8) {
                Text("Icons").font(.caption.weight(.semibold)).foregroundStyle(Color.appFont)
                ForEach(iconTypes, id: \.self) { type in
                    HStack(spacing: 6) {
                        StatusBadge(type: type, size: .small, variant: .primary)
                        StatusBadge(type: type, size: .small, variant: .secondary)
                    }
                }
            }
            VStack(spacing: 8) {
                Text("Timeframes").font(.caption.weight(.semibold)).foregroundStyle(Color.appFont)
                ForEach(timeframeLabels, id: \.self) { label in
                    let type = BadgeType.timeframe(label)
                    HStack(spacing: 6) {
                        StatusBadge(type: type, size: .small, variant: .primary)
                        StatusBadge(type: type, size: .small, variant: .secondary)
                    }
                }
            }
        }
        .padding(24)
    }
    .frame(maxWidth: .infinity)
    .background(Color.appBg)
    
    
}
