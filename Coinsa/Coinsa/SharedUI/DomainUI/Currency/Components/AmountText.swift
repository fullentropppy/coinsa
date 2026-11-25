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

    @Environment(\.locale) private var locale
    
    private let amount: Double
    private let fractionLength: Int
    private let font: Font
    private let color: Color
    private let currency: Currency?
    private let currencyFont: Font?
    private let currencyColor: Color?
    private let usesAdaptiveFormatting: Bool
    
    // MARK: - Инициализация
    
    /// Создает текстовое представление суммы.
    /// - Parameters:
    ///   - amount: Числовое значение суммы.
    ///   - fractionLength: Количество знаков после запятой. По умолчанию `2`.
    ///   - font: Шрифт для числа. По умолчанию `.body`.
    ///   - color: Цвет числа. По умолчанию `.primary`.
    ///   - currency: Валюта (опционально).
    ///   - currencyFont: Шрифт для кода валюты (если не указан, используется `font`).
    ///   - currencyColor: Цвет кода валюты (если не указан, используется `color`).
    ///   - usesAdaptiveFormatting: Сокращать сумму при нехватке ширины. По умолчанию `true`.
    init(
        _ amount: Double,
        fractionLength: Int = 2,
        font: Font = .body,
        color: Color = .primary,
        currency: Currency? = nil,
        currencyFont: Font? = nil,
        currencyColor: Color? = nil,
        usesAdaptiveFormatting: Bool = true
    ) {
        self.amount = amount
        self.fractionLength = max(0, fractionLength)
        self.font = font
        self.color = color
        self.currency = currency
        self.currencyFont = currency == nil ? nil : (currencyFont ?? font)
        self.currencyColor = currency == nil ? nil : (currencyColor ?? color)
        self.usesAdaptiveFormatting = usesAdaptiveFormatting
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if usesAdaptiveFormatting {
            ViewThatFits(in: .horizontal) {
                amountContent(amount.numberFormat(fractionLength: fractionLength, locale: locale))
                    .fixedSize(horizontal: true, vertical: false)
                amountContent(amount.compactNumberFormat(fractionLength: fractionLength, locale: locale))
            }
            .lineLimit(1)
            .minimumScaleFactor(ViewLayout.Label.minimumAmountScaleFactor)
        } else {
            amountContent(amount.numberFormat(fractionLength: fractionLength))
        }
    }

    // MARK: - Компоненты

    private func amountContent(_ formattedAmount: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: ViewLayout.Label.iconSpacing) {
            Text(verbatim: formattedAmount)
                .font(font)
                .foregroundStyle(color)
            
            if let currency, let currencyFont, let currencyColor {
                CurrencyCodeText(currency, font: currencyFont, color: currencyColor)
                    .fixedSize(horizontal: usesAdaptiveFormatting, vertical: false)
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
    ///   - color: Цвет числа; код валюты сохраняет вторичный цвет.
    ///   - usesAdaptiveFormatting: Сокращать сумму при нехватке ширины. По умолчанию `true`.
    /// - Returns: Настроенное представление.
    static func standard(
        _ amount: Double,
        fractionLength: Int = 2,
        currency: Currency? = nil,
        color: Color = .primary,
        usesAdaptiveFormatting: Bool = true
    ) -> some View {
        AmountText(
            amount,
            fractionLength: fractionLength,
            font: .body.monospacedDigit(),
            color: color,
            currency: currency,
            currencyFont: .body.monospaced().weight(.medium),
            currencyColor: .secondary,
            usesAdaptiveFormatting: usesAdaptiveFormatting
        )
    }
    
    /// Компактное вторичное представление суммы (мелкий шрифт).
    /// - Parameters:
    ///   - amount: Сумма.
    ///   - fractionLength: Количество знаков после запятой.
    ///   - currency: Валюта (опционально).
    ///   - usesAdaptiveFormatting: Сокращать сумму при нехватке ширины.
    /// - Returns: Настроенное представление.
    static func secondarySmall(
        _ amount: Double,
        fractionLength: Int = 2,
        currency: Currency? = nil,
        usesAdaptiveFormatting: Bool = false
    ) -> some View {
        AmountText(
            amount,
            fractionLength: fractionLength,
            font: .footnote.monospacedDigit(),
            color: .secondary,
            currency: currency,
            currencyFont: .footnote.monospaced().weight(.medium),
            usesAdaptiveFormatting: usesAdaptiveFormatting
        )
    }
}

// MARK: - Превью

#Preview {
    let amount = 12345.6789
    let currency = Currency.defaultValue
    
    VStack(spacing: 40) {
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
}
