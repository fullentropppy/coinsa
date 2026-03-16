//
//  LocationAmountCardView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.03.2026.
//

import SwiftUI

struct LocationAmountCardView: View {
    // MARK: - Stored Properties
    
    let title: LocalizedStringKey
    let localAmount: Double
    let localCurrencyOption: CurrencyOption
    let baseAmount: Double
    let baseCurrencyOption: CurrencyOption
    let tint: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            AmountText(amount: baseAmount, currencyOption: baseCurrencyOption)
            AmountText(amount: localAmount, currencyOption: localCurrencyOption, style: .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(tint.opacity(0.4).gradient)
        )
    }
}

// MARK: - Preview

private extension LocationAmountCardView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            LocationAmountCardView(
                title: "amount.planned",
                localAmount: 299.55,
                localCurrencyOption: .eur,
                baseAmount: 3012.21,
                baseCurrencyOption: .rub,
                tint: .blue
            )
            LocationAmountCardView(
                title: "amount.actual",
                localAmount: 1094.10,
                localCurrencyOption: .usd,
                baseAmount: 96771.0,
                baseCurrencyOption: .rub,
                tint: .yellow
            )
            LocationAmountCardView(
                title: "amount.actual",
                localAmount: 45000.0,
                localCurrencyOption: .jpy,
                baseAmount: 22675.5,
                baseCurrencyOption: .rub,
                tint: .green
            )
            LocationAmountCardView(
                title: "amount.actual",
                localAmount: -9209.07,
                localCurrencyOption: .krw,
                baseAmount: -499.26,
                baseCurrencyOption: .rub,
                tint: .red
            )
        }
        .padding(100)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
        
    }
}

#Preview("Light - RU") {
    LocationAmountCardView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    LocationAmountCardView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
