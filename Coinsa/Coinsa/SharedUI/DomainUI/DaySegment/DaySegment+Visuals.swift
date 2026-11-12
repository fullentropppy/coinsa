//
//  DaySegment+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

extension DaySegment: ValueVisualRepresentable {
    /// Основная иконка для части дня (контурная версия).
    var primaryIcon: String {
        switch self {
        case .night: "moon.stars"
        case .dawn: "sunrise"
        case .earlyMorning: "sun.horizon"
        case .morning: "sun.min"
        case .afternoon: "sun.max"
        case .lateAfternoon: "sun.min"
        case .evening: "sunset"
        case .lateEvening: "moon.stars"
        }
    }
    
    /// Вторичная иконка для части дня (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .night: "moon.stars.fill"
        case .dawn: "sunrise"
        case .earlyMorning: "sun.horizon.fill"
        case .morning: "sun.min.fill"
        case .afternoon: "sun.min.fill"
        case .lateAfternoon: "sun.haze.fill"
        case .evening: "sunset.fill"
        case .lateEvening: "moon.stars.fill"
        }
    }
}
