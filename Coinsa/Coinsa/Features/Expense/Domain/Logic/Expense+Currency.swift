//
//  Expense+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Expense {
    var baseCurrency: Currency {
        location.baseCurrency
    }
    
    var localCurrency: Currency {
        location.localCurrency
    }
}
