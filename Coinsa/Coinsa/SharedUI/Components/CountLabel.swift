//
//  CountLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.04.2026.
//

import SwiftUI

/// Метка для отображения числового значения с иконкой.
struct CountLabel: View {
    // MARK: - Свойства
    
    private let count: Int
    private let font: Font
    private let color: Color
    private let icon: String
    
    // MARK: - Инициализация
    
    /// Создает метку с числом и иконкой.
    /// - Parameters:
    ///   - count: Отображаемое число.
    ///   - font: Шрифт текста. По умолчанию - `.body`.
    ///   - color: Цвет текста и иконки. По умолчанию - `.primary`.
    ///   - icon: Название системной иконки. По умолчанию `AppSymbols.number`.
    init(_ count: Int, font: Font = .body, color: Color = .primary, icon: String = AppSymbols.number) {
        self.count = count
        self.font = font
        self.color = color
        self.icon = icon
    }
    
    // MARK: - Тело View
    var body: some View {
        HStack(spacing: ViewLayout.Label.compactIconSpacing) {
            AppIcon(icon, style: .inlineMetadata)
            Text(String(count))
        }
        .font(font)
        .foregroundStyle(color)
    }
}

// MARK: - Предопределенные варианты

extension CountLabel {
    /// Вторичная компактная метка (мелкий шрифт, вторичный цвет).
    /// - Parameters:
    ///   - count: Отображаемое число.
    ///   - icon: Название системной иконки. По умолчанию `AppSymbols.number`.
    /// - Returns: Настроенная метка.
    static func secondarySmall(_ count: Int, icon: String = AppSymbols.number) -> some View {
        CountLabel(count, font: AppTextStyle.secondaryNumber.font, color: AppTextStyle.secondaryNumber.color, icon: icon)
    }
    
    /// Метка для отображения количества дней.
    /// - Parameters:
    ///   - days: Количество дней.
    ///   - font: Шрифт текста. По умолчанию `.body`.
    ///   - color: Цвет текста и иконки. По умолчанию `.primary`.
    /// - Returns: Настроенная метка.
    static func days(_ days: Int, font: Font = .body.monospacedDigit(), color: Color = .primary) -> some View {
        CountLabel(days, font: font, color: color, icon: AppSymbols.calendar)
    }
    
    /// Вторичная компактная метка для дней (мелкий шрифт, вторичный цвет).
    /// - Parameter days: Количество дней.
    /// - Returns: Настроенная метка.
    static func daysSecondarySmall(_ days: Int) -> some View {
        CountLabel.days(days, font: AppTextStyle.secondaryNumber.font, color: AppTextStyle.secondaryNumber.color)
    }
}

// MARK: - Превью

#Preview {
    let count = 14
    
    VStack(spacing: 40) {
        VStack(spacing: 20) {
            CountLabel(count)
            CountLabel(count, font: .footnote.monospacedDigit(), color: .accent)
        }
        VStack(spacing: 20) {
            CountLabel.days(count)
            CountLabel.daysSecondarySmall(count)
        }
    }
}

#Preview{
    VStack(alignment: .leading, spacing: 20) {
        CountLabel.secondarySmall(0, icon: Expense.primaryIcon)
        CountLabel.secondarySmall(12345, icon: Expense.primaryIcon)
        CountLabel.daysSecondarySmall(1)
        CountLabel.daysSecondarySmall(365)
    }
    .padding()
}
