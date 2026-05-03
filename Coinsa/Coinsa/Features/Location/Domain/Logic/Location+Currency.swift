//
//  Location+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Location {
    /// Основная валюта (из родительской поездки или значение по умолчанию).
    var baseCurrency: Currency {
        if let trip {
            trip.baseCurrency
        } else {
            .defaultValue
        }
    }
    
    /// Локальная валюта локации (из кода валюты).
    var localCurrency: Currency {
        Currency.from(localCurrencyCode)
    }
}
