//
//  MajorTimeZone+TimeZone.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.04.2026.
//

import Foundation

extension MajorTimeZone {
    var timeZone: TimeZone {
        TimeZone(identifier: self.identifier) ?? .current
    }
    
    var gmtOffsetSeconds: Int {
        timeZone.secondsFromGMT()
    }
    
    var gmtOffsetHours: Double {
        Double(gmtOffsetSeconds).rounded() / 3600
    }
}
