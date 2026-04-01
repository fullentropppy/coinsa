//
//  AmountText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

struct AmountText: View {
    // MARK: - Stored Properties
    
    private let amount: Double
    private let fractionLength: Int
    private let font: Font
    private let color: Color
    private let currency: Currency?
    private let currencyFont: Font?
    private let currencyColor: Color?
    
    // MARK: - Initialization
    
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
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(amount, format: .number.precision(.fractionLength(fractionLength)))
                .font(font)
                .foregroundStyle(color)
            
            if let currency, let currencyFont, let currencyColor {
                CurrencyCodeText(currency, font: currencyFont, color: currencyColor)
            }
        }
    }
}

// MARK: - Presets

extension AmountText {
    static func standard(
        _ amount: Double,
        fractionLength: Int = 2,
        currency: Currency? = nil
    ) -> AmountText {
        AmountText(
            amount,
            fractionLength: fractionLength,
            currency: currency,
            currencyColor: .secondary
        )
    }

    static func secondarySmall(
        _ amount: Double,
        fractionLength: Int = 2,
        currency: Currency? = nil
    ) -> AmountText {
        AmountText(
            amount,
            fractionLength: fractionLength,
            font: .footnote,
            color: .secondary,
            currency: currency
        )
    }
}

// MARK: - Previews

private extension AmountText {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let amount = 12345.6789
        let currency = Currency.rub
        
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
    AmountText.makePreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    AmountText.makePreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
