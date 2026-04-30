//
//  Expense+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Expense {
    var baseCurrency: Currency {
        if let location {
            location.baseCurrency
        } else {
            .defaultValue
        }
    }
    
    var localCurrency: Currency {
        if let location {
            location.localCurrency
        } else {
            .defaultValue
        }
    }
}
