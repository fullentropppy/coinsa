//
//  AmountText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.03.2026.
//

import SwiftUI

struct AmountText: View {
    // MARK: - Stored Properties
    
    let amount: Double
    let currency: Currency?
    let style: ComponentStyle
    let tint: Color?
    
    // MARK: - Initialization
    
    init(
        amount: Double,
        currency: Currency? = nil,
        style: ComponentStyle = .default,
        tint: Color? = nil
    ) {
        self.amount = amount
        self.currency = currency
        self.style = style
        self.tint = tint
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 4) {
            Text(amount, format: .number.precision(.fractionLength(2)))
                .font(styleFont)
                .foregroundStyle(resolvedColor)
            
            if let currency {
                CurrencyCodeText(currency: currency, style: style, tint: tint)
            }
        }
    }
    
    // MARK: - Components
    
    private var styleFont: Font {
        switch style {
        case .default:
            return .body
        case .primary:
            return .headline
        case .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    private var styleColor: Color {
        switch style {
        case .default, .primary:
            return .primary
        default:
            return .secondary
        }
    }
    
    private var resolvedColor: Color {
        tint ?? styleColor
    }
}

// MARK: - Previews

private extension AmountText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            AmountText(amount: 65099.99, currency: Currency.rub, style: .default)
            AmountText(amount: 65099.99, style: .default)
            AmountText(amount: 9032.50, currency: Currency.usd, style: .primary)
            AmountText(amount: 9032.50, style: .primary)
            AmountText(amount: 501.0, currency: Currency.eur, style: .secondary)
            AmountText(amount: 501.0, style: .secondary)
            AmountText(amount: 99.09, currency: Currency.jpy, style: .tertiary)
            AmountText(amount: 99.09, style: .tertiary)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    AmountText.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    AmountText.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
