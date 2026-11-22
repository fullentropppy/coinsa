//
//  ChartPalette.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import SwiftUI

/// Палитра серий диаграмм с устойчивой генерацией дополнительных оттенков.
enum ChartPalette {
    // MARK: - Свойства

    /// Цвета первых двадцати серий в порядке назначения.
    private static let seriesColors: [Color] = [
        .Chart.series01, .Chart.series02, .Chart.series03, .Chart.series04, .Chart.series05,
        .Chart.series06, .Chart.series07, .Chart.series08, .Chart.series09, .Chart.series10,
        .Chart.series11, .Chart.series12, .Chart.series13, .Chart.series14, .Chart.series15,
        .Chart.series16, .Chart.series17, .Chart.series18, .Chart.series19, .Chart.series20
    ]
    /// Насыщенность дополнительных оттенков после исчерпания палитры.
    private static let generatedColorSaturation: Double = 0.65
    /// Яркость дополнительных оттенков после исчерпания палитры.
    private static let generatedColorBrightness: Double = 0.85

    // MARK: - Методы

    /// Возвращает цвет серии из палитры или вычисляет его по постоянному идентификатору.
    /// - Parameters:
    ///   - index: Индекс серии в устойчивом порядке, начиная с нуля.
    ///   - id: Идентификатор для генерации цвета после первых двадцати серий.
    static func color(at index: Int, id: UUID) -> Color {
        if seriesColors.indices.contains(index) {
            return seriesColors[index]
        }

        let uuid = id.uuid
        let hueSeed = (UInt16(uuid.0) << UInt8.bitWidth) | UInt16(uuid.1)
        return Color(
            hue: Double(hueSeed) / Double(UInt16.max),
            saturation: generatedColorSaturation,
            brightness: generatedColorBrightness
        )
    }
}
