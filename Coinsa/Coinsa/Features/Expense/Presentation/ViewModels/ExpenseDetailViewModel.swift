//
//  ExpenseDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.04.2026.
//

import Foundation

struct ExpenseDetailViewModel {
    // MARK: - Хранимые свойства

    let expense: Expense

    // MARK: - Вычисляемые свойства. Общее

    var isHomeLocation: Bool {
        baseCurrency == localCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        expense.category.localizedResource
    }
    
    var navigationSubtitle: String {
        expense.location?.screenContextSubtitle ?? ""
    }
    
    // MARK: - Вычисляемые свойства. Валюта и сумма
    
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

    // MARK: - Вычисляемые свойства. Курс обмена
    
    var exchangeRateDescription: LocalizedStringResource? {
        guard !isHomeLocation else {
            return nil
        }

        if expense.paymentMethod == .card && expense.exchangeAdjustment > 0 {
            return .expenseAdjustedExchangeRateLong(
                localCurrencyCode: expense.localCurrency.code,
                effectiveRateLocalToBase: expense.effectiveRateLocalToBase.numberFormat(fractionLength: 4),
                baseCurrencyCode: expense.baseCurrency.code,
                adjustmentRateLocalToBase: (expense.exchangeAdjustment / 100).percentFormat()
            )
        } else {
            return .expenseBaseExchangeRate(
                localCurrencyCode: expense.localCurrency.code,
                rateLocalToBase: expense.rateLocalToBase.numberFormat(fractionLength: 4),
                baseCurrencyCode: expense.baseCurrency.code
            )
        }
    }
}
