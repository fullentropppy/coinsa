//
//  TimeZone+Offset.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.07.2026.
//

import Foundation

// Данные по смещениям часового пояса.
extension TimeZone {
    /// Смещение от GMT в часах.
    var gmtOffsetHours: Double {
        Double(secondsFromGMT()).rounded() / 3600
    }
    
    // Текстовое представление смещения от GMT в часах.
    var gmtOffsetDisplay: String {
        let seconds = self.secondsFromGMT()
        let hours = gmtOffsetHours
        let formattedHours = hours.numberFormat(fractionLength: 0)
        let minutes = abs(seconds % 3600) / 60
        let formattedMinutes = minutes.formatted(.number.precision(.fractionLength(0)))
        
        var displayedOffset: String = ""

        if hours >= 0 {
            if minutes > 0 {
                displayedOffset = "GMT+\(formattedHours):\(formattedMinutes)"
            } else {
                displayedOffset = "GMT+\(formattedHours)"
            }
        } else {
            if minutes > 0 {
                displayedOffset = "GMT\(formattedHours):\(formattedMinutes)"
            } else {
                displayedOffset = "GMT\(formattedHours)"
            }
        }
        
        return displayedOffset
    }
}
