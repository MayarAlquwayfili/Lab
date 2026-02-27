//
//  FontRegistration.swift
//  SSC_Lab
//
//

import CoreText
import Foundation

enum FontRegistration {


    private static let fontFiles: [(name: String, nameNoSpaces: String?, ext: String)] = [
        ("Londrina Outline Regular", "LondrinaOutline-Regular", "ttf"),
        ("Londrina Solid Regular", "LondrinaSolid-Regular", "ttf"),
    ]

    /// Registers custom fonts from the bundle so they are available globally.
   
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
