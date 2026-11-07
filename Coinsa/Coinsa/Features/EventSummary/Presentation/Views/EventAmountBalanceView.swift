//
//  EventAmountBalanceView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.04.2026.
//

import SwiftUI

/// Представление баланса с прогресс-баром.
struct EventAmountBalanceView: View {
    // MARK: - Хранимые свойства
    
    private let budgetHomeAmount: Double
    private let homeAmountBalance: Double
    private let homeCurrency: Currency
    private let locationAmountBalance: Double?
    private let locationCurrency: Currency?
    
    // MARK: - Вычисляемые свойства
    
    private var progress: Double {
        budgetHomeAmount > 0 ? homeAmountBalance / budgetHomeAmount : 0
    }
    
    // MARK: - Инициализация
    
    /// Создает представление баланса.
    /// - Parameters:
    ///   - budgetHomeAmount: Cумма бюджета в доманей валюте.
    ///   - homeAmountBalance: Остаток в домашней валюте.
    ///   - homeCurrency: Домашняя валюта.
    ///   - locationAmountBalance: Остаток в валюте локации (опционально).
    ///   - locationCurrency: Валюта локации (опционально).
    init(
        budgetHomeAmount: Double,
        homeAmountBalance: Double,
        homeCurrency: Currency,
        locationAmountBalance: Double? = nil,
        locationCurrency: Currency? = nil
    ) {
        self.budgetHomeAmount = budgetHomeAmount
        self.homeAmountBalance = homeAmountBalance
        self.homeCurrency = homeCurrency
        self.locationAmountBalance = locationAmountBalance
        self.locationCurrency = locationCurrency
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .leading) {
            ProgressBar(currentValue: homeAmountBalance, maxValue: budgetHomeAmount, style: .positive)
            HStack {
                Text(.amountBalancePercentage(balancePercent: progress.percentFormat()))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                differenceInfo
            }
        }
    }
    
    // MARK: - Компоненты
    
    private var differenceInfo: some View {
        Group {
            if let locationAmountBalance, let locationCurrency {
                Text(
                    .amountDuo(
                        locationAmountBalance: locationAmountBalance.numberFormat(),
                        locationCurrencyCode: locationCurrency.code,
                        homeAmountBalance: homeAmountBalance.numberFormat(),
                        homeCurrencyCode: homeCurrency.code
                    )
                )
            } else {
                Text(
                    .amountMono(
                        homeAmountBalance: homeAmountBalance.numberFormat(),
                        homeCurrencyCode: homeCurrency.code
                    )
                )
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Превью

#Preview {
    Form {
        Section {
            EventAmountBalanceView(
                budgetHomeAmount: 42000,
                homeAmountBalance: -24600,
                homeCurrency: .defaultValue,
                locationAmountBalance: -41000,
                locationCurrency: .jpy
            )
            EventAmountBalanceView(
                budgetHomeAmount: 42000,
                homeAmountBalance: 0,
                homeCurrency: .defaultValue,
                locationAmountBalance: 0,
                locationCurrency: .jpy
            )
            EventAmountBalanceView(
                budgetHomeAmount: 42000,
                homeAmountBalance: 24600,
                homeCurrency: .defaultValue,
                locationAmountBalance: 41000,
                locationCurrency: .jpy
            )
        }
        Section {
            EventAmountBalanceView(
                budgetHomeAmount: 42000,
                homeAmountBalance: -24600,
                homeCurrency: .defaultValue
            )
            EventAmountBalanceView(
                budgetHomeAmount: 42000,
                homeAmountBalance: 0,
                homeCurrency: .defaultValue
            )
            EventAmountBalanceView(
                budgetHomeAmount: 42000,
                homeAmountBalance: 24600,
                homeCurrency: .defaultValue
            )
        }
    }
}
