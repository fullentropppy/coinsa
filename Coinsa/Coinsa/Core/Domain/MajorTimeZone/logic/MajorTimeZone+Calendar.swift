//
//  MajorTimeZone+Calendar.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import Foundation

extension MajorTimeZone {
    /// Календарь, настроенный на текущий часовой пояс.
    var calendar: Calendar {
        timeZone.calendar
    }
}
