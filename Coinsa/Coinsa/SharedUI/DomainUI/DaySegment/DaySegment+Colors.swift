//
//  DaySegment+Colors.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.09.2026.
//

import SwiftUI

extension DaySegment {
    /// Четырёхступенчатый градиент одного оттенка с настройкой насыщенности и яркости.
    func gradient(for colorScheme: ColorScheme) -> Gradient {
        let palette: (hue: Double, saturation: Double, brightness: Double)
        let isDark = colorScheme == .dark

        switch self {
        case .night:
            palette = isDark ? (0.64, 0.64, 0.38) : (0.64, 0.44, 0.98)
        case .dawn:
            palette = isDark ? (0.85, 0.25, 0.31) : (0.86, 0.17, 0.86)
        case .earlyMorning:
            palette = isDark ? (0.09, 0.61, 0.38) : (0.09, 0.42, 0.98)
        case .morning:
            palette = isDark ? (0.53, 0.49, 0.38) : (0.53, 0.34, 0.98)
        case .afternoon:
            palette = isDark ? (0.57, 0.62, 0.38) : (0.57, 0.43, 0.98)
        case .lateAfternoon:
            palette = isDark ? (0.11, 0.37, 0.36) : (0.11, 0.25, 0.94)
        case .evening:
            palette = isDark ? (0.94, 0.48, 0.38) : (0.94, 0.33, 0.98)
        case .lateEvening:
            palette = isDark ? (0.72, 0.52, 0.36) : (0.72, 0.36, 0.94)
        }

        let stages: [(location: Double, saturationFactor: Double, brightness: Double)] = [
            (0.0, 1.0, isDark ? 0.5 : 1),
            (0.1, isDark ? 0.8 : 0.85, isDark ? 0.48 : 0.99),
            (0.5, isDark ? 0.3 : 0.44, isDark ? 0.28 : 0.94),
            (1.0, isDark ? 0.1 : 0.15, isDark ? 0.10 : 0.92)
        ]

        return Gradient(stops: stages.map { stage in
            .init(
                color: Color(
                    hue: palette.hue,
                    saturation: palette.saturation * stage.saturationFactor,
                    brightness: stage.brightness
                ),
                location: stage.location
            )
        })
    }
}
