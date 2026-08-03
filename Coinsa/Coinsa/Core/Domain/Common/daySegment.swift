//
//  daySegment.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

import Foundation

/// Часть суток.
enum daySegment: CaseIterable {
    case night
    case morning
    case afternoon
    case evening
    
    static func from(date: Date) -> daySegment {
        from(hour: date.hour)
    }
    
    static func from(civilDateTime: CivilDateTime) -> daySegment {
        from(hour: civilDateTime.storedDate.hour)
    }
    
    static func from(hour: Int) -> daySegment {
        switch hour {
        case 6..<12: .morning
        case 12..<18: .afternoon
        case 18..<24: .evening
        default: .night
        }
    }
}
