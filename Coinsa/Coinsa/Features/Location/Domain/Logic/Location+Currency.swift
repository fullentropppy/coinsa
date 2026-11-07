//
//  Location+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Location {
    /// Домашняя валюта (из родительской поездки или значение по умолчанию).
    var homeCurrency: Currency {
        if let trip {
            trip.homeCurrency
        } else {
            .defaultValue
        }
    }
    
    /// Валюта локации (из кода валюты).
    var locationCurrency: Currency {
        Currency.from(locationCurrencyCode)
    }
}
