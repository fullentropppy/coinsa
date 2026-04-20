//
//  MajorTimeZone+Display.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import Foundation

extension MajorTimeZone {
    var offsetDisplay: String {
        let totalSeconds = gmtOffsetSeconds
        let hours = totalSeconds / 3600
        let minutes = abs(totalSeconds % 3600) / 60
        
        if minutes == 0 {
            return "\(hours >= 0 ? "+" : "-")\(abs(hours))"
        } else {
            return "\(hours >= 0 ? "+" : "-")\(abs(hours)):\(String(format: "%02d", minutes))"
        }
    }
    
    var gmtOffsetDisplay: String {
        "GMT\(offsetDisplay)"
    }
}
