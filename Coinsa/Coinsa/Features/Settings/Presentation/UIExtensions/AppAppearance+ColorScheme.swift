//
//  AppAppearance+ColorScheme.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import SwiftUI

extension AppAppearance {
    /// Преобразует режим внешнего вида в ColorScheme.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
