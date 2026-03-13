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
    let currencyOption: CurrencyOption
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Text(amount, format: .number.precision(.fractionLength(2)))
                .font(.headline)
                .foregroundStyle(.primary)
            CurrencyCodeText(currencyOption: currencyOption)
        }
    }
}

// MARK: - Previews

private extension AmountText {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            AmountText(amount: 5.04, currencyOption: CurrencyOption.usd)
            AmountText(amount: 78.0, currencyOption: CurrencyOption.eur)
            AmountText(amount: 181.98, currencyOption: CurrencyOption.cny)
            AmountText(amount: 4903.5, currencyOption: CurrencyOption.aed)
            AmountText(amount: 24600.0, currencyOption: CurrencyOption.try)
            AmountText(amount: 220592.43, currencyOption: CurrencyOption.rub)
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
