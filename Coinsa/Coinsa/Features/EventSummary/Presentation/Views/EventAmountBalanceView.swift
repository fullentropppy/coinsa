//
//  EventAmountDifferenceView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.04.2026.
//

import SwiftUI

/// Представление баланса с прогресс-баром.
struct EventAmountBalanceView: View {
    // MARK: - Хранимые свойства
    
    private let budgetBaseAmount: Double
    private let baseAmountBalance: Double
    private let baseCurrency: Currency
    private let locationAmountBalance: Double?
    private let locationCurrency: Currency?
    
    // MARK: - Вычисляемые свойства
    
    private var progress: Double {
        budgetBaseAmount > 0 ? baseAmountBalance / budgetBaseAmount : 0
    }
    
    // MARK: - Инициализация
    
    /// Создает представление баланса.
    /// - Parameters:
    ///   - budgetBaseAmount: Плановая сумма.
    ///   - baseAmountBalance: Остаток в основной валюте.
    ///   - baseCurrency: Основная валюта.
    ///   - locationAmountBalance: Остаток в локальной валюте (опционально).
    ///   - locationCurrency: Локальная валюта (опционально).
    init(
        budgetBaseAmount: Double,
        baseAmountBalance: Double,
        baseCurrency: Currency,
        locationAmountBalance: Double? = nil,
        locationCurrency: Currency? = nil
    ) {
        self.budgetBaseAmount = budgetBaseAmount
        self.baseAmountBalance = baseAmountBalance
        self.baseCurrency = baseCurrency
        self.locationAmountBalance = locationAmountBalance
        self.locationCurrency = locationCurrency
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .leading) {
            ProgressBar(currentValue: baseAmountBalance, maxValue: budgetBaseAmount, style: .positive)
            HStack {
                Text(.amountBalancePersentage(balancePercent: progress.percentFormat()))
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
                        baseAmountBalance: baseAmountBalance.numberFormat(),
                        baseCurrencyCode: baseCurrency.code
                    )
                )
            } else {
                Text(
                    .amountMono(
                        baseAmountBalance: baseAmountBalance.numberFormat(),
                        baseCurrencyCode: baseCurrency.code
                    )
                )
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}

// MARK: - Превью

private extension EventAmountBalanceView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        Form {
            Section {
                EventAmountBalanceView(
                    budgetBaseAmount: 42000,
                    baseAmountBalance: -24600,
                    baseCurrency: .defaultValue,
                    locationAmountBalance: -41000,
                    locationCurrency: .jpy
                )
                EventAmountBalanceView(
                    budgetBaseAmount: 42000,
                    baseAmountBalance: 0,
                    baseCurrency: .defaultValue,
                    locationAmountBalance: 0,
                    locationCurrency: .jpy
                )
                EventAmountBalanceView(
                    budgetBaseAmount: 42000,
                    baseAmountBalance: 24600,
                    baseCurrency: .defaultValue,
                    locationAmountBalance: 41000,
                    locationCurrency: .jpy
                )
            }
            Section {
                EventAmountBalanceView(
                    budgetBaseAmount: 42000,
                    baseAmountBalance: -24600,
                    baseCurrency: .defaultValue
                )
                EventAmountBalanceView(
                    budgetBaseAmount: 42000,
                    baseAmountBalance: 0,
                    baseCurrency: .defaultValue
                )
                EventAmountBalanceView(
                    budgetBaseAmount: 42000,
                    baseAmountBalance: 24600,
                    baseCurrency: .defaultValue
                )
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAmountBalanceView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAmountBalanceView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

