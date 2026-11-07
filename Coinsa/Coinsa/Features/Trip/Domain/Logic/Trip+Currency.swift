//
//  Trip+Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Trip {
    /// Домашняя валюта поездки (из кода валюты).
    var homeCurrency: Currency {
        Currency.from(baseCurrencyCode)
    }
}
