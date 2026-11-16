//
//  ProgressBar.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.04.2026.
//

import SwiftUI

/// Индикатор прогресса в виде капсулы.
struct ProgressBar: View {
    // MARK: - Константы

    private enum Layout {
        /// Высота полосы прогресса.
        static let height: CGFloat = 10
        /// Непрозрачность фоновой дорожки прогресса.
        static let trackOpacity: Double = 0.2
        /// Длительность анимации изменения заполнения.
        static let animationDuration: TimeInterval = 0.2
    }

    // MARK: - Вложенные типы
    
    /// Стиль отображения прогресс-бара.
    enum Style {
        /// Обычный стиль (зеленая полоса).
        case plain
        
        /// Положительный прогресс (зеленеет при достижении цели).
        case positive
        
        /// Отрицательный прогресс (краснеет при превышении).
        case negative
    }

    
    // MARK: - Свойства
    
    private let currentValue: Double
    private let maxValue: Double
    private let style: Style
    
    private var progress: Double {
        maxValue > 0 ? max(min(currentValue / maxValue, 1), 0) : 0
    }

    private var backgroundFill: Color {
        if style == .positive && progress == 0 {
            ProgressBarPalette.critical
        } else if style == .negative && progress == 0 {
            ProgressBarPalette.plain
        } else {
            .secondary
        }
    }
    
    private var barFill: Color {
        switch style {
        case .plain:
            ProgressBarPalette.plain
        case .positive:
            ProgressBarPalette.color(for: progress)
        case .negative:
            ProgressBarPalette.color(for: progress, reversed: true)
        }
    }
    
    // MARK: - Инициализация
    
    /// Создает индикатор прогресса.
    /// - Parameters:
    ///   - currentValue: Текущее значение.
    ///   - maxValue: Максимальное значение (цель).
    ///   - style: Стиль отображения. По умолчанию `.plain`.
    init(currentValue: Double, maxValue: Double, style: Style = .plain) {
        self.currentValue = currentValue
        self.maxValue = maxValue
        self.style = style
    }
    
    // MARK: - Тело View
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundFill.opacity(Layout.trackOpacity))
                
                Capsule()
                    .fill(barFill.gradient)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: Layout.height)
        .animation(.easeInOut(duration: Layout.animationDuration), value: progress)
    }

}

// MARK: - Превью

#Preview {
    let maxValue: Double = 100
    
    Form {
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
}
