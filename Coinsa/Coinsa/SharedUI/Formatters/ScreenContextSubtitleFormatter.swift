//
//  ScreenContextSubtitleFormatter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.03.2026.
//

import Foundation

/// Форматтер для создания контекстного подзаголовка экрана.
struct ScreenContextSubtitleFormatter {
    /// Формирует подзаголовок из родительского заголовка и диапазона дат.
    /// - Parameters:
    ///   - parentTitle: Заголовок родительского объекта.
    ///   - startDate: Начальная дата диапазона.
    ///   - endDate: Конечная дата диапазона.
    ///   - calendar: Календарь для вычислений. По умолчанию `.current`.
    /// - Returns: Стркоа подзаголовка.
    static func format(
        parentTitle: String,
        startDate: PlainDate,
        endDate: PlainDate
    ) -> String {
        let dateRange = DateDisplayFormatter.formatRange(
            startDate: startDate,
            endDate: endDate
        )

        guard !parentTitle.isEmpty else {
            return dateRange
        }

        return "\(parentTitle) • \(dateRange)"
    }
}
