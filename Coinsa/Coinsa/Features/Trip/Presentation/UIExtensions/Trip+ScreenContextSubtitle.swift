//
//  Trip+ScreenContextSubtitle.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.03.2026.
//

extension Trip {
    /// Контекстный подзаголовок для экрана поездки.
    var screenContextSubtitle: String {
        ScreenContextSubtitleFormatter.format(
            parentTitle: name,
            startDate: startDate,
            endDate: endDate
        )
    }
}
