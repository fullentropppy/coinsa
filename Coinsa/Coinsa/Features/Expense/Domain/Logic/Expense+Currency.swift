//
//  Expense+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Expense {
    /// Основная валюта траты (из родительской поездки).
    var baseCurrency: Currency {
        location?.baseCurrency ?? .defaultValue
    }
    
    /// Локальная валюта траты (из локации).
    var localCurrency: Currency {
        location?.localCurrency ?? .defaultValue
    }
}
