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
    let localCurrency: Currency
    let baseAmount: Double
    let baseCurrency: Currency
    let tint: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            AmountText(amount: baseAmount, currency: baseCurrency)
            AmountText(amount: localAmount, currency: localCurrency, style: .secondary)
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
                localCurrency: .eur,
                baseAmount: 3012.21,
                baseCurrency: .rub,
                tint: .blue
            )
            LocationAmountCardView(
                title: "amount.actual",
                localAmount: 1094.10,
                localCurrency: .usd,
                baseAmount: 96771.0,
                baseCurrency: .rub,
                tint: .yellow
            )
            LocationAmountCardView(
                title: "amount.actual",
                localAmount: 45000.0,
                localCurrency: .jpy,
                baseAmount: 22675.5,
                baseCurrency: .rub,
                tint: .green
            )
            LocationAmountCardView(
                title: "amount.actual",
                localAmount: -9209.07,
                localCurrency: .krw,
                baseAmount: -499.26,
                baseCurrency: .rub,
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
