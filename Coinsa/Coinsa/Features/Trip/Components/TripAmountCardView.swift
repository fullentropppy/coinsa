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
    let currencyCode: String
    let tint: Color

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(formattedAmount).font(.headline).foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(tint.opacity(0.1))
        )
    }

    private var formattedAmount: String {
        amount.formatted(.currency(code: currencyCode).presentation(.isoCode))
    }
}

// MARK: - Preview

#Preview("Light - RU") {
    TripAmountCardView(
        title: "План", amount: 56950.55, currencyCode: "RUB", tint: .blue
    )
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
        .padding()
    
}

#Preview("Dark - EN") {
    TripAmountCardView(
        title: "Planned", amount: 760.25, currencyCode: "RUB", tint: .blue
    )
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
        .padding()
}
