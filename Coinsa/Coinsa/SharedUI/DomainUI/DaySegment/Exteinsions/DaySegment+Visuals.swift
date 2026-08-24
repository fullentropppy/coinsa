//
//  DaySegment+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

import Foundation

extension DaySegment: ValueVisualRepresentable {
    /// Основная иконка для части дня (контурная версия).
    var primaryIcon: String {
        switch self {
        case .night: "moon"
        case .morning: "sunrise"
        case .afternoon: "sun.max"
        case .evening: "sunset"
        }
    }
    
    /// Вторичная иконка для части дня (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .night: "moon.fill"
        case .morning: "sunrise.fill"
        case .afternoon: "sun.max.fill"
        case .evening: "sunset.fill"
        }
    }
}
