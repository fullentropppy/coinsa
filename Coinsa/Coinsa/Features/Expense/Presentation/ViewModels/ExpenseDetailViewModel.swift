//
//  ExpenseDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.04.2026.
//

import Foundation

/// ViewModel для детального экрана траты.
struct ExpenseDetailViewModel {
    // MARK: - Хранимые свойства

    let expense: Expense

    // MARK: - Вычисляемые свойства. Общее

    var isExpenseBaseCurrency: Bool {
        baseCurrency == expenseCurrency
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
    
    var locationCurrency: Currency {
        expense.locationCurrency
    }
    
    var expenseCurrency: Currency {
        expense.expenseCurrency
    }
    
    var primaryAmount: Double {
        isExpenseBaseCurrency ? expense.baseAmount : expense.amount(in: .expense)
    }

    var primaryCurrency: Currency {
        isExpenseBaseCurrency ? baseCurrency : expenseCurrency
    }

    var secondaryAmount: Double? {
        isExpenseBaseCurrency ? nil : expense.baseAmount
    }

    var secondaryCurrency: Currency? {
        isExpenseBaseCurrency ? nil : baseCurrency
    }

    // MARK: - Вычисляемые свойства. Курс обмена
    
    var exchangeRateExpenseToLocationDescription: LocalizedStringResource? {
        guard !isExpenseBaseCurrency && expenseCurrency != locationCurrency else {
            return nil
        }

        if expense.paymentMethod == .card && expense.exchangeAdjustment > 0 {
            return .expenseAdjustedExchangeRateLong(
                quoteCurrencyCode: expense.expenseCurrency.code,
                effectiveRateQuoteToBase: expense.exchangeRate(from: .expense, to: .location, using: .effective)
                    .numberFormat(fractionLength: 4),
                baseCurrencyCode: expense.locationCurrency.code,
                adjustmentRateQuoteToBase: (expense.exchangeAdjustment / 100).percentFormat()
            )
        } else {
            return .expenseBaseExchangeRate(
                quoteCurrencyCode: expense.expenseCurrency.code,
                rateQuoteToBase: expense.rateExpenseToLocation.numberFormat(fractionLength: 4),
                baseCurrencyCode: expense.locationCurrency.code
            )
        }
    }
    
    var exchangeRateExpenseToBaseDescription: LocalizedStringResource? {
        guard !isExpenseBaseCurrency else {
            return nil
        }

        if expense.paymentMethod == .card && expense.exchangeAdjustment > 0 {
            return .expenseAdjustedExchangeRateLong(
                quoteCurrencyCode: expense.expenseCurrency.code,
                effectiveRateQuoteToBase: expense.exchangeRate(from: .expense, to: .base, using: .effective)
                    .numberFormat(fractionLength: 4),
                baseCurrencyCode: expense.baseCurrency.code,
                adjustmentRateQuoteToBase: (expense.exchangeAdjustment / 100).percentFormat()
            )
        } else {
            return .expenseBaseExchangeRate(
                quoteCurrencyCode: expense.expenseCurrency.code,
                rateQuoteToBase: expense.rateExpenseToBase.numberFormat(fractionLength: 4),
                baseCurrencyCode: expense.baseCurrency.code
            )
        }
    }
}
