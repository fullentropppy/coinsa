//
//  AppAppearance+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

extension AppAppearance: ValueVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка режима внешнего вида.
    var primaryIcon: String {
        switch self {
        case .system: AppSymbols.circleRighthalfFilled
        case .light: AppSymbols.circle
        case .dark: AppSymbols.circleFill
        }
    }
}
