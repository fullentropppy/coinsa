//
//  DaySegment+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

extension DaySegment: ValueVisualRepresentable {
    // MARK: - Свойства

    /// Основная иконка для части дня (контурная версия).
    var primaryIcon: String {
        switch self {
        case .night: AppSymbols.moonStars
        case .dawn: AppSymbols.sunrise
        case .earlyMorning: AppSymbols.sunHorizon
        case .morning: AppSymbols.sunMin
        case .afternoon: AppSymbols.sunMax
        case .lateAfternoon: AppSymbols.sunMin
        case .evening: AppSymbols.sunset
        case .lateEvening: AppSymbols.moonStars
        }
    }
    
    /// Вторичная иконка для части дня (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .night: AppSymbols.moonStarsFill
        case .dawn: AppSymbols.sunrise
        case .earlyMorning: AppSymbols.sunHorizonFill
        case .morning: AppSymbols.sunMinFill
        case .afternoon: AppSymbols.sunMinFill
        case .lateAfternoon: AppSymbols.sunHazeFill
        case .evening: AppSymbols.sunsetFill
        case .lateEvening: AppSymbols.moonStarsFill
        }
    }
}
