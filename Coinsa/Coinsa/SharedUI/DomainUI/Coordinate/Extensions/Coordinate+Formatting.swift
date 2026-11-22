//
//  Coordinate+Formatting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.08.2026.
//

import Foundation

extension Coordinate {
    // MARK: - Свойства

    /// Форматированное описание координат для отображения.
    /// Формат: `"широта, долгота ± точность м"` или `"широта, долгота"` если точность неизвестна.
    var formattedDescription: String {
        let coordinateText = String(
            format: "%.5f, %.5f",
            latitude,
            longitude
        )

        if let horizontalAccuracy {
            return coordinateText + String(localized: .coordinateAccuracy(
                accuracy: horizontalAccuracy.numberFormat(fractionLength: 0)
            ))
        } else {
            return coordinateText
        }
    }
}
