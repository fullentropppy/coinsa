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

    // MARK: - Состояние UI. Общее поведение и оформление

    var isHomeLocation: Bool {
        baseCurrency == localCurrency
    }

    var shouldDismiss: Bool {
        expense.modelContext == nil
    }
    
    // MARK: - Состояние UI. Сумма и валюта
    
    var baseCurrency: Currency {
        expense.baseCurrency
    }
    
    var localCurrency: Currency {
        expense.localCurrency
    }
    
    var primaryAmount: Double {
        isHomeLocation ? expense.baseAmount : expense.localAmount
    }

    var primaryCurrency: Currency {
        isHomeLocation ? baseCurrency : localCurrency
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

        if expense.paymentMethod == .card && expense.exchangeAdjustment > 0 {
            return .expenseAdjustedExchangeRateLong(
                localCurrencyCode: expense.localCurrency.code,
                effectiveRateLocalToBase: expense.effectiveRateLocalToBase.formatted(
                    .number.precision(.fractionLength(4))
                ),
                baseCurrencyCode: expense.baseCurrency.code,
                adjustmentRateLocalToBase: (expense.exchangeAdjustment / 100).formatted(
                    .percent.precision(.fractionLength(0...2))
                )
            )
        } else {
            return .expenseBaseExchangeRate(
                localCurrencyCode: expense.localCurrency.code,
                rateLocalToBase: expense.rateLocalToBase.formatted(
                    .number.precision(.fractionLength(4))
                ),
                baseCurrencyCode: expense.baseCurrency.code
            )
        }
    }
}
