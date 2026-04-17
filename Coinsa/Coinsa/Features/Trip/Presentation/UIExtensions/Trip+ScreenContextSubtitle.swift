//
//  Trip+ScreenContextSubtitle.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.03.2026.
//

extension Trip {
    var screenContextSubtitle: String {
        ScreenContextSubtitleFormatter.format(
            parentTitle: name,
            startDate: startDate,
            endDate: endDate
        )
    }
}
