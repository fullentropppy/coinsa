//
//  EventAmountCardView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.04.2026.
//

import SwiftUI

struct EventAmountCardView: View {
    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let baseAmount: Double
    private let baseCurrency: Currency
    private let localAmount: Double?
    private let localCurrency: Currency?

    // MARK: - Инициализация
    
    init(
        title: LocalizedStringResource,
        baseAmount: Double,
        baseCurrency: Currency,
        localAmount: Double? = nil,
        localCurrency: Currency? = nil
    ) {
        self.title = title
        self.baseAmount = baseAmount
        self.baseCurrency = baseCurrency
        self.localAmount = localAmount
        self.localCurrency = localCurrency
    }
    
    // MARK: - Тело View

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.footnote).foregroundStyle(.secondary)
            if let localAmount, let localCurrency {
                AmountText.standard(localAmount, currency: localCurrency)
                Spacer()
                Divider()
                AmountText.secondarySmall(baseAmount, currency: baseCurrency)
            } else {
                AmountText.standard(baseAmount, currency: baseCurrency)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Превью

private extension EventAmountCardView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        Form {
            VStack(spacing: 20) {
                EventAmountCardView(
                    title: .amountActual,
                    baseAmount: 24600,
                    baseCurrency: .defaultValue,
                    localAmount: 41000,
                    localCurrency: .jpy
                )
                EventAmountCardView(
                    title: .amountActual,
                    baseAmount: 24600,
                    baseCurrency: .defaultValue
                )
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAmountCardView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAmountCardView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
