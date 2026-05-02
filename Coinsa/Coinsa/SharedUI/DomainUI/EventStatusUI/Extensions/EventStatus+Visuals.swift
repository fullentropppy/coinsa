//
//  EventStatus+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

extension EventStatus: ValueVisualRepresentable {
    /// Основная иконка для статуса события (контурная версия).
    var primaryIcon: String {
        switch self {
        case .upcoming: "clock"
        case .ongoing: "play.circle"
        case .completed: "checkmark.circle"
        }
    }
    
    /// Вторичная иконка для статуса события (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .upcoming: "clock.fill"
        case .ongoing: "play.circle.fill"
        case .completed: "checkmark.circle.fill"
        }
    }
    
    /// Акцентный цвет для статуса события.
    var accentColor: Color {
        switch self {
        case .upcoming: .teal
        case .ongoing: .green
        case .completed: .gray
        }
    }
}
