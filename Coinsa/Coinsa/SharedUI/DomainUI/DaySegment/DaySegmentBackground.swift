//
//  DaySegmentBackground.swift
//  Coinsa
//
//  Created by Gritsenko Daniil on 12.11.2026.
//

import SwiftUI

/// Фон с градиентом для выбранной части суток.
struct DaySegmentBackground: View {
    let daySegment: DaySegment

    var body: some View {
        LinearGradient(colors: daySegment.colors, startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}
