//
//  CountLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.04.2026.
//

import SwiftUI

struct CountLabel: View {
    // MARK: - Свойства
    
    private let count: Int
    private let font: Font
    private let color: Color
    private let icon: String
    
    // MARK: - Инициализация
    
    init(_ count: Int, font: Font = .body, color: Color = .primary, icon: String = "number") {
        self.count = count
        self.font = font
        self.color = color
        self.icon = icon
    }
    
    // MARK: - Тело View
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .imageScale(.small)
            Text(String(count))
        }
        .font(font)
        .foregroundStyle(color)
    }
}

// MARK: - Предопределенные варианты

extension CountLabel {
    static func secondarySmall(_ count: Int, icon: String = "number") -> some View {
        CountLabel(count, font: .footnote, color: .secondary, icon: icon)
    }
    
    static func days(_ days: Int, font: Font = .body, color: Color = .primary) -> some View {
        CountLabel(days, font: font, color: color, icon: "clock")
    }
    
    static func daysSecondarySmall(_ days: Int) -> some View {
        CountLabel.days(days, font: .footnote, color: .secondary)
    }
}

// MARK: - Превью

private extension CountLabel {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        let count = 14
        
        return VStack(spacing: 40) {
            VStack(spacing: 20) {
                CountLabel(count)
                CountLabel(count, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                CountLabel.days(count)
                CountLabel.daysSecondarySmall(count)
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    CountLabel.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    CountLabel.makePreview(colorScheme: .dark)
}
