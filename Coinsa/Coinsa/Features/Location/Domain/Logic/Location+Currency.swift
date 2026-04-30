//
//  Location+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Location {
    var baseCurrency: Currency {
        if let trip {
            trip.baseCurrency
        } else {
            .defaultValue
        }
    }
    
    var localCurrency: Currency {
        Currency.from(localCurrencyCode)
    }
}
