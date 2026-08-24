//
//  Coordinate+Formatting.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.08.2026.
//

import Foundation

extension Coordinate {
    /// Форматированное описание координат для отображения.
    /// Формат: `"широта, долгота ± точность м"` или `"широта, долгота"` если точность неизвестна.
    var formattedDescription: String {
        let coordinateText = String(
            format: "%.5f, %.5f",
            latitude,
            longitude
        )

        if let horizontalAccuracy {
            return coordinateText + String(format: " ± %.0f m", horizontalAccuracy)
        } else {
            return coordinateText
        }
    }
}
