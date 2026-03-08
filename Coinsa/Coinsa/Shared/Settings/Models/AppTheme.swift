//
//  AppTheme.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .system:
            return "settings.theme.system"
        case .light:
            return "settings.theme.light"
        case .dark:
            return "settings.theme.dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
