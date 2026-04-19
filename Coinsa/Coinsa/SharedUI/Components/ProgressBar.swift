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
            case ..<0.1: return .red
            case ..<0.25: return .orange
            case ..<0.4: return .yellow
            default: return .green
            }
        } else {
            switch progress {
            case ..<0.6: return .green
            case ..<0.75: return .yellow
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
        let maxValue: Double = 100
        
        return Form {
            Section {
                ProgressBar(currentValue: 50, maxValue: maxValue)
            }
            Section {
                ProgressBar(currentValue: 5, maxValue: maxValue, style: .positive)
                ProgressBar(currentValue: 15, maxValue: maxValue, style: .positive)
                ProgressBar(currentValue: 35, maxValue: maxValue, style: .positive)
                ProgressBar(currentValue: 65, maxValue: maxValue, style: .positive)
                ProgressBar(currentValue: 100, maxValue: maxValue, style: .positive)
            }
            Section {
                ProgressBar(currentValue: 5, maxValue: maxValue, style: .negative)
                ProgressBar(currentValue: 40, maxValue: maxValue, style: .negative)
                ProgressBar(currentValue: 60, maxValue: maxValue, style: .negative)
                ProgressBar(currentValue: 80, maxValue: maxValue, style: .negative)
                ProgressBar(currentValue: 100, maxValue: maxValue, style: .negative)
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
