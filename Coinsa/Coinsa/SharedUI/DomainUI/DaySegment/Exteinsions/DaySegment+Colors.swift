//
//  DaySegment+Colors.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.09.2026.
//

import SwiftUI

extension DaySegment {
    // Набор цветов для предсталвения части суток.
    var colors: [Color] {
        var relatedColor: Color
        var topColor: Color
        var bottomColor: Color
        
        switch self {
        case .night:
            relatedColor = .indigo
            topColor = .daySegmentNight2
            bottomColor = .daySegmentNight1
        case .morning:
            relatedColor = .orange
            topColor = .daySegmentMorning2
            bottomColor = .daySegmentMorning1
        case .afternoon:
            relatedColor = .blue
            topColor = .daySegmentAfternoon2
            bottomColor = .daySegmentAfternoon1
        case .evening:
            relatedColor = .red
            topColor = .daySegmentEvening2
            bottomColor = .daySegmentEvening1
        }
        
        return [
            relatedColor.mix(with: topColor, by: 0.8),
            relatedColor.mix(with: topColor, by: 0.9),
            topColor,
            bottomColor,
            .black.opacity(0.15)
        ]
    }
}
