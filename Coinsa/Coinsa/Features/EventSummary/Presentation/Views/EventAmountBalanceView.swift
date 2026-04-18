//
//  EventAmountDifferenceView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 05.04.2026.
//

import SwiftUI

struct EventAmountBalanceView: View {
    // MARK: - Хранимые свойства
    
    private let plannedBaseAmount: Double
    private let baseAmountBalance: Double
    private let baseCurrency: Currency
    private let localAmountBalance: Double?
    private let localCurrency: Currency?
    
    // MARK: - Вычисляемые свойства
    
    private var progress: Double {
        plannedBaseAmount > 0 ? baseAmountBalance / plannedBaseAmount : 0
    }
    
    // MARK: - Инициализация
    
    init(
        plannedBaseAmount: Double,
        baseAmountBalance: Double,
        baseCurrency: Currency,
        localAmountBalance: Double? = nil,
        localCurrency: Currency? = nil
    ) {
        self.plannedBaseAmount = plannedBaseAmount
        self.baseAmountBalance = baseAmountBalance
        self.baseCurrency = baseCurrency
        self.localAmountBalance = localAmountBalance
        self.localCurrency = localCurrency
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .leading) {
            ProgressBar(currentValue: baseAmountBalance, maxValue: plannedBaseAmount, style: .positive)
            HStack {
                Text(.amountBalance(balancePercent: progress.formatted(.percent.precision(.fractionLength(2)))))
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
            if let localAmountBalance, let localCurrency {
                Text(
                    .summaryDuoBalance(
                        localAmountBalance: localAmountBalance.formatted(
                            .number.precision(.fractionLength(2))
                        ),
                        localCurrencyCode: localCurrency.code,
                        baseAmountBalance: baseAmountBalance.formatted(
                            .number.precision(.fractionLength(2))
                        ),
                        baseCurrencyCode: baseCurrency.code
                    )
                )
            } else {
                Text(
                    .summaryMonoBalance(
                        baseAmountBalance: baseAmountBalance.formatted(
                            .number.precision(.fractionLength(2))
                        ),
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
                    plannedBaseAmount: 42000,
                    baseAmountBalance: -24600,
                    baseCurrency: .defaultCurrency,
                    localAmountBalance: -41000,
                    localCurrency: .jpy
                )
                EventAmountBalanceView(
                    plannedBaseAmount: 42000,
                    baseAmountBalance: 0,
                    baseCurrency: .defaultCurrency,
                    localAmountBalance: 0,
                    localCurrency: .jpy
                )
                EventAmountBalanceView(
                    plannedBaseAmount: 42000,
                    baseAmountBalance: 24600,
                    baseCurrency: .defaultCurrency,
                    localAmountBalance: 41000,
                    localCurrency: .jpy
                )
            }
            Section {
                EventAmountBalanceView(
                    plannedBaseAmount: 42000,
                    baseAmountBalance: -24600,
                    baseCurrency: .defaultCurrency
                )
                EventAmountBalanceView(
                    plannedBaseAmount: 42000,
                    baseAmountBalance: 0,
                    baseCurrency: .defaultCurrency
                )
                EventAmountBalanceView(
                    plannedBaseAmount: 42000,
                    baseAmountBalance: 24600,
                    baseCurrency: .defaultCurrency
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

