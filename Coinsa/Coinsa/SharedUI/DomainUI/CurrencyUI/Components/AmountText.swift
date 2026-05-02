//
//  AmountText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

/// Текстовое представление денежной суммы.
struct AmountText: View {
    // MARK: - Свойства
    
    private let amount: Double
    private let fractionLength: Int
    private let font: Font
    private let color: Color
    private let currency: Currency?
    private let currencyFont: Font?
    private let currencyColor: Color?
    
    // MARK: - Инициализация
    
    /// Создаёт текстовое представление суммы.
    /// - Parameters:
    ///   - amount: Числовое значение суммы.
    ///   - fractionLength: Количество знаков после запятой. По умолчанию `2`.
    ///   - font: Шрифт для числа. По умолчанию `.body`.
    ///   - color: Цвет числа. По умолчанию `.primary`.
    ///   - currency: Валюта (опционально).
    ///   - currencyFont: Шрифт для кода валюты (если не указан, используется `font`).
    ///   - currencyColor: Цвет кода валюты (если не указан, используется `color`).
    init(
        _ amount: Double,
        fractionLength: Int = 2,
        font: Font = .body,
        color: Color = .primary,
        currency: Currency? = nil,
        currencyFont: Font? = nil,
        currencyColor: Color? = nil
    ) {
        self.amount = amount
        self.fractionLength = max(0, fractionLength)
        self.font = font
        self.color = color
        self.currency = currency
        self.currencyFont = currency == nil ? nil : (currencyFont ?? font)
        self.currencyColor = currency == nil ? nil : (currencyColor ?? color)
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(amount.numberFormat(fractionLength: fractionLength))
                .font(font)
                .foregroundStyle(color)
            
            if let currency, let currencyFont, let currencyColor {
                CurrencyCodeText(currency, font: currencyFont, color: currencyColor)
            }
        }
    }
}

// MARK: - Предопределенные варианты

extension AmountText {
    /// Стандартное представление суммы с моноширинными цифрами.
    /// - Parameters:
    ///   - amount: Сумма.
    ///   - fractionLength: Количество знаков после запятой.
    ///   - currency: Валюта (опционально).
    /// - Returns: Настроенное представление.
    static func standard(
        _ amount: Double,
        fractionLength: Int = 2,
        currency: Currency? = nil
    ) -> some View {
        AmountText(
            amount,
            fractionLength: fractionLength,
            font: .body.monospacedDigit(),
            currency: currency,
            currencyFont: .body.monospaced().weight(.medium),
            currencyColor: .secondary
        )
    }
    
    /// Компактное вторичное представление суммы (мелкий шрифт).
    /// - Parameters:
    ///   - amount: Сумма.
    ///   - fractionLength: Количество знаков после запятой.
    ///   - currency: Валюта (опционально).
    /// - Returns: Настроенное представление.
    static func secondarySmall(
        _ amount: Double,
        fractionLength: Int = 2,
        currency: Currency? = nil
    ) -> some View {
        AmountText(
            amount,
            fractionLength: fractionLength,
            font: .footnote.monospacedDigit(),
            color: .secondary,
            currency: currency,
            currencyFont: .footnote.monospaced().weight(.medium)
        )
    }
}

// MARK: - Превью

private extension AmountText {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let amount = 12345.6789
        let currency = Currency.defaultValue
        
        return VStack(spacing: 40) {
            VStack(spacing: 20) {
                AmountText(amount)
                AmountText(amount, fractionLength: 4, font: .footnote, color: .accent)
            }
            VStack(spacing: 20) {
                AmountText(amount, currency: currency)
                AmountText(
                    amount,
                    fractionLength: 4,
                    font: .footnote,
                    color: .accent,
                    currency: currency,
                    currencyFont: .footnote,
                    currencyColor: .accent.opacity(0.5)
                )
            }
            VStack(spacing: 20) {
                AmountText.standard(amount, currency: currency)
                AmountText.secondarySmall(amount, currency: currency)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    AmountText.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    AmountText.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
