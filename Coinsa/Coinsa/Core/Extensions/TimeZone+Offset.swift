//
//  TimeZone+Offset.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.07.2026.
//

import Foundation

/// Данные по смещениям часового пояса.
extension TimeZone {
    /// Смещение от GMT в часах.
    var gmtOffsetHours: Double {
        Double(secondsFromGMT()) / 3600
    }
    
    /// Текстовое представление смещения от GMT в часах.
    var gmtOffsetDisplay: String {
        let seconds = secondsFromGMT()
        let sign = seconds >= 0 ? "+" : "-"
        let absoluteSeconds = abs(seconds)
        let hours = absoluteSeconds / 3600
        let minutes = absoluteSeconds % 3600 / 60

        if minutes > 0 {
            return "GMT\(sign)\(hours):\(String(format: "%02d", minutes))"
        } else {
            return "GMT\(sign)\(hours)"
        }
    }
}
