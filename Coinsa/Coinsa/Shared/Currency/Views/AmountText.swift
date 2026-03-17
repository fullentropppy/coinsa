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
    let currencyOption: CurrencyOption?
    let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(
        amount: Double,
        currencyOption: CurrencyOption? = nil,
        style: ComponentStyle = .default
    ) {
        self.amount = amount
        self.currencyOption = currencyOption
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 4) {
            Text(amount, format: .number.precision(.fractionLength(2)))
                .font(amountFont)
                .foregroundStyle(amountColor)
            
            if let currencyOption {
                CurrencyCodeText(currencyOption: currencyOption, style: style)
            }
        }
    }
    
    // MARK: - Components
    
    private var amountFont: Font {
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
    
    var amountColor: Color {
        switch style {
        case .default, .primary:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension AmountText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            AmountText(amount: 65099.99, currencyOption: CurrencyOption.rub, style: .default)
            AmountText(amount: 65099.99, style: .default)
            AmountText(amount: 9032.50, currencyOption: CurrencyOption.usd, style: .primary)
            AmountText(amount: 9032.50, style: .primary)
            AmountText(amount: 501.0, currencyOption: CurrencyOption.eur, style: .secondary)
            AmountText(amount: 501.0, style: .secondary)
            AmountText(amount: 99.09, currencyOption: CurrencyOption.jpy, style: .tertiary)
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
