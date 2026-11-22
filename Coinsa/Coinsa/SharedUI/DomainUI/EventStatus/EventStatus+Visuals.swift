//
//  EventStatus+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

extension EventStatus: ValueVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка для статуса события (контурная версия).
    var primaryIcon: String {
        switch self {
        case .upcoming: AppSymbols.clock
        case .ongoing: AppSymbols.playCircle
        case .completed: AppSymbols.checkmarkCircle
        }
    }
    
    /// Вторичная иконка для статуса события (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .upcoming: AppSymbols.clockFill
        case .ongoing: AppSymbols.playCircleFill
        case .completed: AppSymbols.checkmarkCircleFill
        }
    }
    
    /// Акцентный цвет для статуса события.
    var accentColor: Color {
        switch self {
        case .upcoming: .EventStatuses.upcoming
        case .ongoing: .EventStatuses.ongoing
        case .completed: .EventStatuses.completed
        }
    }
}
