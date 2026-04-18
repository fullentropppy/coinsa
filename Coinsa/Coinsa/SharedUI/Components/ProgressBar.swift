//
//  ProgressBar.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.04.2026.
//

import SwiftUI

// MARK: - Публичные типы

enum progressBarStyle {
    case plain
    case positive
    case negative
}

struct ProgressBar: View {
    // MARK: - Свойства
    
    let currentValue: Double
    let maxValue: Double
    let style: progressBarStyle
    
    private var progress: Double {
        maxValue > 0 ? max(min(currentValue / maxValue, 1), 0) : 0
    }

    private var backgroundFill: Color {
        if style == .positive && progress == 0 {
            return .red
        } else {
            return .secondary
        }
    }
    
    private var barFill: Color {
        if style == .plain {
            return .green
        } else if style == .positive {
            switch progress {
            case ..<0.2: return .red
            case ..<0.4: return .orange
            case ..<0.6: return .yellow
            default: return .green
            }
        } else {
            switch progress {
            case ..<0.7: return .green
            case ..<0.8: return .yellow
            case ..<0.9: return .orange
            default: return .red
            }
        }
    }
    
    // MARK: - Инициализация
    
    init(currentValue: Double, maxValue: Double, style: progressBarStyle = .plain) {
        self.currentValue = currentValue
        self.maxValue = maxValue
        self.style = style
    }
    
    // MARK: - Тело View
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundFill.opacity(0.2))
                
                Capsule()
                    .fill(barFill)
                    .frame(width: geo.size.width * progress)
                    .glassEffect(.clear)
            }
        }
        .frame(height: 10)
        .animation(.easeInOut(duration: 0.2), value: progress)
    }

}

// MARK: - Превью

private extension ProgressBar {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        let maxValue: Double = 205
        
        return Form {
            Section {
                ForEach(Array(stride(from: 5, through: maxValue, by: 100)), id: \.self) { value in
                    ProgressBar(currentValue: value, maxValue: maxValue)
                }
            }
            Section {
                ForEach(Array(stride(from: 5, through: maxValue, by: 50)), id: \.self) { value in
                    ProgressBar(currentValue: value, maxValue: maxValue, style: .positive)
                }
            }
            Section {
                ForEach(Array(stride(from: 5, through: maxValue, by: 50)), id: \.self) { value in
                    ProgressBar(currentValue: value, maxValue: maxValue, style: .negative)
                }
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    ProgressBar.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    ProgressBar.makePreview(colorScheme: .dark)
}
