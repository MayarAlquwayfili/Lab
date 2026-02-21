//
//  StatusGroup.swift
//  SSC_Lab
//
//  Created by yumii on 11/02/2026.
//

import SwiftUI

struct StatusGroup: View {
    var items: [BadgeType]
    var size: BadgeSize = .small
    var variant: BadgeVariant = .primary

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if items.count == 4 {
                ForEach(0..<3, id: \.self) { index in
                    StatusBadge(type: items[index], size: size, variant: variant)
                }
                Spacer(minLength: 50)
                StatusBadge(type: items[3], size: size, variant: variant)
            } else {
                ForEach(Array(items.enumerated()), id: \.offset) { _, type in
                    StatusBadge(type: type, size: size, variant: variant)
                }
            }
        }
        .padding([.horizontal, .bottom], 10)
    }
}

// MARK: - Previews
#Preview("StatusGroup – Top Badge (1 item)") {
    StatusGroup(items: [.indoor], size: .small, variant: .primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appBg)
}

#Preview("StatusGroup – Lab View (3 items)") {
    StatusGroup(
        items: [.indoor, .tools, .timeframe("1D")],
        size: .small,
        variant: .primary
    )
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.appBg)
}

#Preview("StatusGroup – Wins View (Real Card Width 181)") {
    VStack {
        StatusGroup(
            items: [.outdoor, .noTools, .timeframe("+30D"), .oneTime],
            size: .small,
            variant: .primary
        )
        .frame(width: 181)
    }
    .padding()
 }
