//
//  MajorTimeZone+TimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

import Foundation

extension MajorTimeZone {
    /// Системный часовой пояс устройства.
    static var systemTimeZone: TimeZone {
        .current
    }
    
    /// Объект `TimeZone`, соответствующий часовому поясу.
    var timeZone: TimeZone {
        TimeZone(identifier: id) ?? .current
    }
    
    /// Смещение от GMT в секундах.
    var gmtOffsetSeconds: Int {
        timeZone.secondsFromGMT()
    }
    
    /// Смещение от GMT в часах.
    var gmtOffsetHours: Double {
        Double(gmtOffsetSeconds).rounded() / 3600
    }
}
