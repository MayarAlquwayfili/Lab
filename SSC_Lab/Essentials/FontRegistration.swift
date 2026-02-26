//
//  FontRegistration.swift
//  SSC_Lab
//
//  Registers custom fonts at runtime using CTFontManagerRegisterFontsForURL
//  so they are available without Info.plist font entries.
//

import CoreText
import Foundation

enum FontRegistration {

    /// Original names (with spaces) and no-space fallbacks. Tries both; bundle is searched entirely.
    private static let fontFiles: [(name: String, nameNoSpaces: String?, ext: String)] = [
        ("Bobby Jones Soft", "BobbyJonesSoft", "otf"),
        ("Bobby Jones Soft Outline", "BobbyJonesSoftOutline", "otf"),
    ]

    /// Registers custom fonts from the bundle so they are available globally.
    /// Call once from your App's init(). Searches the entire bundle (no subdirectory).
    /// Tries both spaced and no-space resource names (e.g. Bobby Jones Soft / BobbyJonesSoft).
    static func registerCustomFonts(bundle: Bundle = .main) {
        for (name, nameNoSpaces, ext) in fontFiles {
            let namesToTry = [name] + (nameNoSpaces.map { [$0] } ?? [])
            for resourceName in namesToTry {
                guard let url = bundle.url(forResource: resourceName, withExtension: ext) else { continue }
                registerFont(at: url)
                break
            }
        }
    }

    private static func registerFont(at url: URL) {
        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
    }
}
