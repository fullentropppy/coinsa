//
//  Trip+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Trip {
    /// Основная валюта поездки (из кода валюты).
    var baseCurrency: Currency {
        Currency.from(baseCurrencyCode)
    }
}
