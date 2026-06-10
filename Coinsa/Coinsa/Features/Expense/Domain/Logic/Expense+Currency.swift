//
//  Expense+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

extension Expense {
    /// Основная валюта траты (из родительской поездки).
    var baseCurrency: Currency {
        location?.baseCurrency ?? .defaultValue
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
