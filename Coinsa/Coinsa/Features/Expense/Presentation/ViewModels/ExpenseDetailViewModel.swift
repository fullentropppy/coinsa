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

    var isExpenseHomeCurrency: Bool {
        homeCurrency == expenseCurrency
    }
    
    var isExpenseLocationCurrency: Bool {
        locationCurrency == expenseCurrency
    }
    
    var isLocationhomeCurrency: Bool {
        homeCurrency == locationCurrency
    }
    
    var navigationTitle: LocalizedStringResource {
        expense.category.localizedResource
    }
    
    var navigationSubtitle: String {
        expense.location?.screenContextSubtitle ?? ""
    }
    
    // MARK: - Вычисляемые свойства. Валюта и сумма
    
    var homeCurrency: Currency {
        expense.homeCurrency
    }
    
    var locationCurrency: Currency {
        expense.locationCurrency
    }
    
    var expenseCurrency: Currency {
        expense.expenseCurrency
    }
    
    var primaryAmount: Double {
        isExpenseHomeCurrency ? expense.homeAmount : expense.amount(in: .expense)
    }

    var primaryCurrency: Currency {
        isExpenseHomeCurrency ? homeCurrency : expenseCurrency
    }

    var secondaryAmount: Double? {
        isExpenseHomeCurrency ? nil : expense.homeAmount
    }

    var secondaryCurrency: Currency? {
        isExpenseHomeCurrency ? nil : homeCurrency
    }

    // MARK: - Вычисляемые свойства. Карта
    
    var coordinate: CLLocationCoordinate2D? {
        expense.coordinate?.coreLocationCoordinate
    }
    
    var cameraCoreCoordinate: CLLocationCoordinate2D? {
        guard let coordinate else { return nil }
        
        var shift: Double
        
        if !isExpenseHomeCurrency && expense.comment != nil {
            shift = 0.013
        } else if isExpenseHomeCurrency && expense.comment != nil
                    || !isExpenseHomeCurrency && expense.comment == nil {
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
        guard !isExpenseHomeCurrency || !isLocationhomeCurrency else {
            return nil
        }
        
        if isExpenseHomeCurrency {
            return .expenseActualExchangeRate(
                expenseCurrencyCode: expenseCurrency.code,
                actualRateExpenseToHome: expense
                    .rateExpenseToLocation
                    .numberFormat(fractionLength: 4),
                homeCurrencyCode: locationCurrency.code
            )
        } else if expense.exchangeAdjustment > 0 && expense.paymentMethod != .cash {
            if isExpenseLocationCurrency || isLocationhomeCurrency {
                return .expenseAdjustedExchangeRateLong(
                    expenseCurrencyCode: expenseCurrency.code,
                    effectiveRateExpenseToHome: expense
                        .exchangeRate(from: .expense, to: .home, using: .effective)
                        .numberFormat(fractionLength: 4),
                    homeCurrencyCode: homeCurrency.code,
                    exchangeAdjustment: (expense.exchangeAdjustment / 100).percentFormat()
                )
            } else {
                return .expenseAdjustedExchangeRateLongDouble(
                    expenseCurrencyCode: expenseCurrency.code,
                    effectiveRateExpenseToHome: expense
                        .exchangeRate(from: .expense, to: .home, using: .effective)
                        .numberFormat(fractionLength: 4),
                    homeCurrencyCode: homeCurrency.code,
                    effectiveRateExpenseToLocation: expense
                        .exchangeRate(from: .expense, to: .location, using: .effective)
                        .numberFormat(fractionLength: 4),
                    locationCurrencyCode: locationCurrency.code,
                    exchangeAdjustment: (expense.exchangeAdjustment / 100).percentFormat()
                )
            }
        } else {
            if isExpenseLocationCurrency || isLocationhomeCurrency {
                return .expenseActualExchangeRate(
                    expenseCurrencyCode: expenseCurrency.code,
                    actualRateExpenseToHome: expense
                        .rateExpenseToHome
                        .numberFormat(fractionLength: 4),
                    homeCurrencyCode: homeCurrency.code
                )
            } else {
                return .expenseActualExchangeRateDouble(
                    expenseCurrencyCode: expenseCurrency.code,
                    actualRateExpenseToHome: expense
                        .rateExpenseToHome
                        .numberFormat(fractionLength: 4),
                    homeCurrencyCode: homeCurrency.code,
                    actualRateExpenseToLocation: expense
                        .rateExpenseToLocation
                        .numberFormat(fractionLength: 4),
                    locationCurrencyCode: locationCurrency.code
                )
            }
        }
    }
}
