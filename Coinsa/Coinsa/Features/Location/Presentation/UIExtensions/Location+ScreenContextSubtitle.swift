//
//  Location+ScreenContextSubtitle.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.03.2026.
//

import Foundation

/// Контекстный подзаголовок для экрана локации.
extension Location {
    var screenContextSubtitle: String {
        ScreenContextSubtitleFormatter.format(
            parentTitle: name,
            startDate: startPlainDate,
            endDate: endPlainDate
        )
    }
}
