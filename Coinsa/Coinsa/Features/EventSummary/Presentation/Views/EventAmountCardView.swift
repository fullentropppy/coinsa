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
    private let homeAmount: Double
    private let homeCurrency: Currency
    private let locationAmount: Double?
    private let locationCurrency: Currency?
    
    // MARK: - Инициализация
    
    /// Создает карточку с суммой.
    /// - Parameters:
    ///   - title: Заголовок.
    ///   - homeAmount: Сумма в домашней валюте.
    ///   - homeCurrency: Домашняя валюта.
    ///   - locationAmount: Сумма в валюте локации (опционально).
    ///   - locationCurrency: Валюта локации (опционально).
    init(
        title: LocalizedStringResource,
        homeAmount: Double,
        homeCurrency: Currency,
        locationAmount: Double? = nil,
        locationCurrency: Currency? = nil
    ) {
        self.title = title
        self.homeAmount = homeAmount
        self.homeCurrency = homeCurrency
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
                AmountText.secondarySmall(homeAmount, currency: homeCurrency)
            } else {
                AmountText.standard(homeAmount, currency: homeCurrency)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(10)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Превью

#Preview {
    Form {
        VStack(spacing: 20) {
            EventAmountCardView(
                title: .amountExpenses,
                homeAmount: 24600,
                homeCurrency: .defaultValue,
                locationAmount: 41000,
                locationCurrency: .jpy
            )
            EventAmountCardView(
                title: .amountExpenses,
                homeAmount: 24600,
                homeCurrency: .defaultValue
            )
        }
    }
}
