//
//  Trip+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.04.2026.
//

import Foundation

extension Trip {
    var baseCurrency: Currency {
        Currency.from(baseCurrencyCode)
    }
}
