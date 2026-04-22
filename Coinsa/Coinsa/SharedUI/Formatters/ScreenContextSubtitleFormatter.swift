//
//  ScreenContextSubtitleFormatter.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.03.2026.
//

import Foundation

struct ScreenContextSubtitleFormatter {
    static func format(
        parentTitle: String,
        startDate: Date,
        endDate: Date,
        using calendar: Calendar = .current
    ) -> String {
        let dateRange = DateDisplayFormatter.formatRange(
            startDate: startDate,
            endDate: endDate,
            using: calendar
        )

        guard !parentTitle.isEmpty else {
            return dateRange
        }

        return "\(parentTitle) • \(dateRange)"
    }
}
