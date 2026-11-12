//
//  DaySegmentBackground.swift
//  Coinsa
//
//  Created by Gritsenko Daniil on 12.11.2026.
//

import SwiftUI

/// Фон с градиентом для выбранной части суток.
struct DaySegmentBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    let daySegment: DaySegment

    var body: some View {
        LinearGradient(gradient: daySegment.gradient(for: colorScheme), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
        ForEach(DaySegment.allCases, id: \.self) { segment in
            VStack(spacing: 14) {
                Image(systemName: segment.primaryIcon)
                    .font(.title2)
                Text(segment.localizedResource)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(DaySegmentBackground(daySegment: segment))
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
    }
    .padding()
}
