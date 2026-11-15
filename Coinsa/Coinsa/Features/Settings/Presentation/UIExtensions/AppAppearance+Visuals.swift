//
//  AppAppearance+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

extension AppAppearance: ValueVisualRepresentable {
    /// Основная иконка режима внешнего вида.
    var primaryIcon: String {
        switch self {
        case .system: "circle.righthalf.filled"
        case .light: "circle"
        case .dark: "circle.fill"
        }
    }
}
