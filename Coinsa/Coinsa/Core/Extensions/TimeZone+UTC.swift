//
//  TimeZone+UTC.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.07.2026.
//

import Foundation

/// Фиксированный часовой пояс UTC+0.
extension TimeZone {
    static var utc: TimeZone {
        TimeZone(secondsFromGMT: 0)!
    }
}
