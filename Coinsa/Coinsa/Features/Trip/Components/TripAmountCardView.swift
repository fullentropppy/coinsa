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
    let currency: Currency
    let tint: Color

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            AmountText(amount: amount, currency: currency)
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
                title: "amount.planned",
                amount: 299.55,
                currency: Currency.eur,
                tint: .blue
            )
            TripAmountCardView(
                title: "amount.actual",
                amount: 3512.01,
                currency: Currency.usd,
                tint: .yellow
            )
            TripAmountCardView(
                title: "amount.difference",
                amount: 19500.0,
                currency: Currency.rub,
                tint: .green
            )
            TripAmountCardView(
                title: "amount.difference",
                amount: -33075.25,
                currency: Currency.rub,
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
