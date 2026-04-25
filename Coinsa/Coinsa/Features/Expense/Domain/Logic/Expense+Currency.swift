//
//  Expense+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Expense {
    var baseCurrencyCode: String {
        location.baseCurrencyCode
    }
    
    var baseCurrency: Currency {
        location.baseCurrency
    }
    
    var localCurrencyCode: String {
        location.localCurrencyCode
    }
    
    var localCurrency: Currency {
        location.localCurrency
    }
}
