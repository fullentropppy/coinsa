//
//  ExpenseDetailViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.04.2026.
//

import Foundation
import MapKit

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

    // MARK: - Вычисляемые свойства. Карта
    
    var coordinate: CLLocationCoordinate2D? {
        expense.coordinate?.coreLocationCoordinate
    }
    
    var cameraCoreCoordinate: CLLocationCoordinate2D? {
        guard let coordinate else { return nil }
        
        var shift: Double
        
        if !isExpenseBaseCurrency && expense.comment != nil {
            shift = 0.013
        } else if isExpenseBaseCurrency && expense.comment != nil
                    || !isExpenseBaseCurrency && expense.comment == nil {
            shift = 0.010
        } else {
            shift = 0.008
        }
        
        return CLLocationCoordinate2D(
            latitude: coordinate.latitude + shift,
            longitude: coordinate.longitude
        )
    }
    
    // MARK: - Вычисляемые свойства. Курс обмена
    
    var exchangeRateDescription: LocalizedStringResource? {
        guard !isExpenseBaseCurrency else{
            return nil
        }
        
        let hasExchangeAdjustment = expense.exchangeAdjustment > 0 && expense.paymentMethod != .cash
        
        if isExpenseBaseCurrency && hasExchangeAdjustment {
            return .expenseAdjustedExchangeRateLong(
                expenseCurrencyCode: expenseCurrency.code,
                effectiveRateExpenseToBase: expense.rateExpenseToBase
                    .numberFormat(fractionLength: 4),
                baseCurrencyCode: baseCurrency.code,
                exchangeAdjustment: (expense.exchangeAdjustment / 100).percentFormat()
            )
        } else if isExpenseBaseCurrency && !hasExchangeAdjustment {
            return .expenseActualExchangeRate(
                expenseCurrencyCode: expenseCurrency.code,
                actualRateExpenseToBase: expense.rateExpenseToBase
                    .numberFormat(fractionLength: 4),
                baseCurrencyCode: baseCurrency.code
            )
        } else if !isExpenseBaseCurrency && hasExchangeAdjustment {
            return .expenseAdjustedExchangeRateLongDouble(
                expenseCurrencyCode: expenseCurrency.code,
                effectiveRateExpenseToBase: expense.rateExpenseToBase
                    .numberFormat(fractionLength: 4),
                baseCurrencyCode: baseCurrency.code,
                effectiveRateExpenseToLocation: expense.rateExpenseToLocation
                    .numberFormat(fractionLength: 4),
                locationCurrencyCode: locationCurrency.code,
                exchangeAdjustment: (expense.exchangeAdjustment / 100).percentFormat()
            )
        } else {
            return .expenseActualExchangeRateDouble(
                expenseCurrencyCode: expenseCurrency.code,
                actualRateExpenseToBase: expense.rateExpenseToBase
                    .numberFormat(fractionLength: 4),
                baseCurrencyCode: baseCurrency.code,
                actualRateExpenseToLocation: expense.rateExpenseToLocation
                    .numberFormat(fractionLength: 4),
                locationCurrencyCode: locationCurrency.code
            )
        }
    }
}
