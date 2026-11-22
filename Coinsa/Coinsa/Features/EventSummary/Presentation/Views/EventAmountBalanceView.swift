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

    @Environment(\.locale) private var locale
    
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
            ViewThatFits(in: .horizontal) {
                balanceRow(usesCompactFormatting: false)
                balanceRow(usesCompactFormatting: true)
            }
            .appTextStyle(.secondaryFootnote)
            .lineLimit(1)
            .minimumScaleFactor(ViewLayout.Label.minimumAmountScaleFactor)
        }
    }
    
    // MARK: - Компоненты
    
    private func balanceRow(usesCompactFormatting: Bool) -> some View {
        HStack {
            Text(.amountBalancePercentage(balancePercent: progress.percentFormat(locale: locale)))
                .fixedSize(horizontal: !usesCompactFormatting, vertical: false)
            Spacer()
            balanceText(usesCompactFormatting: usesCompactFormatting)
                .fixedSize(horizontal: !usesCompactFormatting, vertical: false)
        }
    }

    private func balanceText(usesCompactFormatting: Bool) -> Text {
        if let locationAmountBalance, let locationCurrency {
            Text(
                .amountDuo(
                    locationAmountBalance: formattedAmount(locationAmountBalance, usesCompactFormatting: usesCompactFormatting),
                    locationCurrencyCode: locationCurrency.code,
                    homeAmountBalance: formattedAmount(homeAmountBalance, usesCompactFormatting: usesCompactFormatting),
                    homeCurrencyCode: homeCurrency.code
                )
            )
        } else {
            Text(
                .amountMono(
                    homeAmountBalance: formattedAmount(homeAmountBalance, usesCompactFormatting: usesCompactFormatting),
                    homeCurrencyCode: homeCurrency.code
                )
            )
        }
    }

    private func formattedAmount(_ amount: Double, usesCompactFormatting: Bool) -> String {
        if usesCompactFormatting {
            amount.compactNumberFormat(locale: locale)
        } else {
            amount.numberFormat(locale: locale)
        }
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
