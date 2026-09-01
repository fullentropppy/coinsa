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
        var colors: [Color] = []
        
        switch self {
        case .night:
            colors.append(.indigo.mix(with: Color.daySegmentNight2, by: 0.9))
            colors.append(Color.daySegmentNight2)
            colors.append(Color.daySegmentNight1)
        case .morning:
            colors.append(.yellow.mix(with: Color.daySegmentMorning2, by: 0.9))
            colors.append(Color.daySegmentMorning2)
            colors.append(Color.daySegmentMorning1)
        case .afternoon:
            colors.append(.blue.mix(with: Color.daySegmentAfternoon2, by: 0.9))
            colors.append(Color.daySegmentAfternoon2)
            colors.append(Color.daySegmentAfternoon1)
        case .evening:
            colors.append(.red.mix(with: Color.daySegmentEvening2, by: 0.9))
            colors.append(Color.daySegmentEvening2)
            colors.append(Color.daySegmentEvening1)
        }
        
        colors.append(.black.opacity(0.1))
        
        return colors
    }
}
