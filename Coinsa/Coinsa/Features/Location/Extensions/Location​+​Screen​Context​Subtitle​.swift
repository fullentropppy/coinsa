//
//  Location​+​Screen​Context​Subtitle​.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.03.2026.
//

import Foundation

extension Location {
    var screenContextSubtitle: String {
        ScreenContextSubtitleFormatter.format(
            parentTitle: name,
            startDate: startDate,
            endDate: endDate
        )
    }
}
