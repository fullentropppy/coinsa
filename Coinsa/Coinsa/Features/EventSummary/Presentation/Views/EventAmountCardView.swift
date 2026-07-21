//
//  EventAmountCardView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.04.2026.
//

import SwiftUI

/// Карточка с суммой в одной или двух валютах.
struct EventAmountCardView: View {
    // MARK: - Свойства
    
    private let title: LocalizedStringResource
    private let baseAmount: Double
    private let baseCurrency: Currency
    private let locationAmount: Double?
    private let locationCurrency: Currency?
    
    // MARK: - Инициализация
    
    /// Создает карточку с суммой.
    /// - Parameters:
    ///   - title: Заголовок.
    ///   - baseAmount: Сумма в основной валюте.
    ///   - baseCurrency: Основная валюта.
    ///   - locationAmount: Сумма валюте локации (опционально).
    ///   - locationCurrency: Валюта локации (опционально).
    init(
        title: LocalizedStringResource,
        baseAmount: Double,
        baseCurrency: Currency,
        locationAmount: Double? = nil,
        locationCurrency: Currency? = nil
    ) {
        self.title = title
        self.baseAmount = baseAmount
        self.baseCurrency = baseCurrency
        self.locationAmount = locationAmount
        self.locationCurrency = locationCurrency
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.footnote).foregroundStyle(.secondary)
            if let locationAmount, let locationCurrency {
                AmountText.standard(locationAmount, currency: locationCurrency)
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
                    title: .amountExpenses,
                    baseAmount: 24600,
                    baseCurrency: .defaultValue,
                    locationAmount: 41000,
                    locationCurrency: .jpy
                )
                EventAmountCardView(
                    title: .amountExpenses,
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
