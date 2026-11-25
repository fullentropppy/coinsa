//
//  Expense+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

extension Expense {
    // MARK: - Свойства

    /// Домашняя валюта траты (из родительской поездки).
    var homeCurrency: Currency {
        owningTrip?.homeCurrency ?? .defaultValue
    }
    
    /// Валюта локации; у общей траты совпадает с домашней валютой.
    var locationCurrency: Currency {
        location?.locationCurrency ?? homeCurrency
    }
    
    /// Валюта, в которой была совершена трата.
    var expenseCurrency: Currency {
        if expenseCurrencyCode.isBlank {
            locationCurrency
        } else {
            Currency.from(expenseCurrencyCode)
        }
    }
}
