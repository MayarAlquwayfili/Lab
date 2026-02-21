//
//  Color+Theme.swift
//  SSC_Lab
//
//  Created by yumii on 09/02/2026.
//

import Foundation
import SwiftUI

extension Color {
    static let appBg        = Color("Background")
    static let appFont      = Color("PrimaryColor_Font")
    static let appPrimary   = Color("PrimaryColor")
    static let appSecondary = Color("SecondaryColor")
    static let appPopUp     = Color("PopUp_Color")
    static let appShade01   = Color("Base_Shade_01")
    static let appShade02   = Color("Base_Shade_02")
    static let appAlert     = Color("AlertColor")
    /// Darker tone for close/cancel actions (e.g. X button)
    static var appSecondaryDark: Color { Color.appFont.opacity(0.55) }
}

    
