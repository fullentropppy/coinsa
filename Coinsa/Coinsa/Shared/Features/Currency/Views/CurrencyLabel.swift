//
//  CurrencyLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.04.2026.
//

import SwiftUI

struct CurrencyLabel: View {
    // MARK: - Properties
    var currency: Currency
    
    // MARK: - Initializers
    init(_ currency: Currency) {
        self.currency = currency
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Text(currency.code)
                .foregroundStyle(.secondary)
                .frame(width: 38)
            Text(currency.localizedResource)
        }
    }
}

// MARK: - Preview
private extension CurrencyLabel {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(Currency.allCases, id: \.id) { currency in
                CurrencyLabel(currency)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    CurrencyLabel.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    CurrencyLabel.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
