//
//  TripAmountCardView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct TripAmountCardView: View {
    // MARK: - Stored Properties

    let title: LocalizedStringKey
    let amount: Double
    let currencyOption: CurrencyOption
    let tint: Color

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            AmountText(amount: amount, currencyOption: currencyOption)
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

private extension TripAmountCardView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            TripAmountCardView(
                title: "trip.detail.summary.planned",
                amount: 299.55,
                currencyOption: CurrencyOption.eur,
                tint: .blue
            )
            TripAmountCardView(
                title: "trip.detail.summary.actual",
                amount: 3512.01,
                currencyOption: CurrencyOption.usd,
                tint: .yellow
            )
            TripAmountCardView(
                title: "trip.detail.summary.difference",
                amount: 19500.0,
                currencyOption: CurrencyOption.rub,
                tint: .green
            )
            TripAmountCardView(
                title: "trip.detail.summary.difference",
                amount: -33075.25,
                currencyOption: CurrencyOption.rub,
                tint: .red
            )
        }
        .padding(100)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
        
    }
}

#Preview("Light - RU") {
    TripAmountCardView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripAmountCardView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
