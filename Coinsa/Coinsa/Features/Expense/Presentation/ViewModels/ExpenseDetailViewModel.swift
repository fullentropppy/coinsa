//
//  ExpenseDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.04.2026.
//

import Foundation
import SwiftData
import SwiftUI

struct ExpenseDetailViewModel {
    // MARK: - Зависимости

    let expense: Expense
    let baseCurrency: Currency

    // MARK: - Инициализация

    init(expense: Expense, baseCurrency: Currency) {
        self.expense = expense
        self.baseCurrency = baseCurrency
    }

    // MARK: - Состояние UI. Общее поведение и оформление

    var isHomeLocation: Bool {
        baseCurrency == expense.localCurrency
    }

    var shouldDismiss: Bool {
        expense.modelContext == nil
    }
    
    // MARK: - Состояние UI. Сумма и валюта
    
    var primaryAmount: Double {
        isHomeLocation ? expense.baseAmount : expense.localAmount
    }

    var primaryCurrency: Currency {
        isHomeLocation ? baseCurrency : expense.localCurrency
    }

    var secondaryAmount: Double? {
        isHomeLocation ? nil : expense.baseAmount
    }

    var secondaryCurrency: Currency? {
        isHomeLocation ? nil : baseCurrency
    }

    // MARK: - Состояние UI. Курс обмена
    
    var exchangeRateDescription: LocalizedStringResource? {
        guard !isHomeLocation else {
            return nil
        }

        if expense.paymentMethod == .card && expense.exchangeAdjustmentPercentage > 0 {
            return .expenseAdjustedExchangeRateLong(
                baseCurrencyCode: baseCurrency.code,
                effectiveRateLocalToBase: expense.effectiveRateLocalToBase.formatted(
                    .number.precision(.fractionLength(4))
                ),
                localCurrencyCode: expense.localCurrency.code,
                adjustmentRateLocalToBase: (expense.exchangeAdjustmentPercentage / 100).formatted(
                    .percent.precision(.fractionLength(0...2))
                )
            )
        } else {
            return .expenseBaseExchangeRate(
                baseCurrencyCode: baseCurrency.code,
                rateLocalToBase: expense.rateLocalToBase.formatted(
                    .number.precision(.fractionLength(4))
                ),
                localCurrencyCode: expense.localCurrency.code
            )
        }
    }
}
