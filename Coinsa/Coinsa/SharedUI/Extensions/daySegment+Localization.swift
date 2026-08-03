//
//  daySegment+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.08.2026.
//

import Foundation

extension daySegment {
    /// Локализованное название части суток.
    var localizedResource: LocalizedStringResource {
        switch self {
        case .night: .daySegmentNight
        case .morning: .daySegmentMorning
        case .afternoon: .daySegmentAfternoon
        case .evening: .daySegmentEvening
        }
    }
}
