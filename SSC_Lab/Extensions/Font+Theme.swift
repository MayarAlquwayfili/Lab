//
//  Font+Theme.swift
//  SSC_Lab
//
//  Created by yumii on 09/02/2026.
//

import Foundation
import SwiftUI

extension Font {
    
 
    // Bobby Jones Soft
    
    /// (36)
    static var appHero: Font {
        .custom("Bobby Jones Soft", size: 36, relativeTo: .largeTitle)
    }
    ///(24) – smaller hero for detail/nav titles
    static var appHeroSmall: Font {
        .custom("Bobby Jones Soft", size: 24, relativeTo: .title2)
    }
    /// Outline (36)
    static var appWin: Font {
        .custom("Bobby Jones Soft Outline", size: 36, relativeTo: .largeTitle)
    }
    /// Outline (64) – outline style for Win detail card title
    static var appHeroOutline: Font {
        .custom("Bobby Jones Soft Outline", size: 64, relativeTo: .title)
    }
    /// (64) – Lab / detail card titles
    static var appDetailCard: Font {
        .custom("Bobby Jones Soft", size: 64, relativeTo: .title)
    }
    /// (24) – empty state title only
    static var appEmptyStateTitle: Font {
        .custom("Bobby Jones Soft", size: 24)
    }

    /// (36)
    static var appCard: Font {
        .custom("Bobby Jones Soft", size: 36, relativeTo: .title)
    }
    

     /// SF Pro Rounded Bold (20)
    static var appTimeframeL_High: Font {
        .system(size: 20, weight: .bold, design: .rounded)
    }
    /// SF Pro Rounded Bold (16)
    static var appTimeframeL_Mid: Font {
        .system(size: 16, weight: .bold, design: .rounded)
    }
    /// SF Pro Rounded Bold (14)
    static var appTimeframeL_Low: Font {
        .system(size: 14, weight: .bold, design: .rounded)
    }

    //Timeframe Small
    /// SF Pro Rounded Bold (10)
    static var appTimeframeS_High: Font {
        .system(size: 10, weight: .bold, design: .rounded)
    }
    /// SF Pro Rounded Bold (8)
    static var appTimeframeS_Low: Font {
        .system(size: 8, weight: .bold, design: .rounded)
    }
    /// SF Pro Medium (20)
    static var appTitle: Font {
        .system(size: 20, weight: .medium, design: .rounded)
    }
    /// SF Pro Semibold (17)
    static var appSubHeadline: Font {
        .system(size: 17, weight: .semibold, design: .rounded)
    }
    /// SF Pro Medium (17)
    static var appBody: Font {
        .system(size: 17, weight: .medium, design: .rounded)
    }
    /// SF Pro Regular (15)
    static var appBodySmall: Font {
        .system(size: 15, weight: .regular, design: .rounded)
    }
    /// SF Pro Italic (12)
    static var appCaption: Font {
        .system(size: 12, weight: .regular, design: .rounded).italic()
    }
    /// SF Pro Rounded Semibold (10) – Tab bar labels
    static var appMicro: Font {
        .system(size: 10, weight: .semibold, design: .rounded)
    }
}
