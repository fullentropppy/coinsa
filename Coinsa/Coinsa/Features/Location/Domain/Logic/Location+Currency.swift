//
//  Location+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.04.2026.
//

import Foundation

extension Location {
    var localCurrency: Currency {
        Currency.from(localCurrencyCode)
    }
}
