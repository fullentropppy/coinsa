//
//  Expense+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

extension Expense {
    /// Домашняя валюта траты (из родительской поездки).
    var homeCurrency: Currency {
        location?.homeCurrency ?? .defaultValue
    }
    
    /// Валюта локации, в которой совершена трата.
    var locationCurrency: Currency {
        location?.locationCurrency ?? .defaultValue
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
