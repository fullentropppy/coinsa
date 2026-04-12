//
//  AppAppearance+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import SwiftUI

extension AppAppearance {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .system: .appAppearanceSystem
        case .light: .appAppearanceLight
        case .dark: .appAppearanceDark
        }
    }
}
