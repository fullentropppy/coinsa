//
//  Currency+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

extension Currency {
    static var defaultCurrency: Currency { Currency.rub }
    static var defaultCurrencyCode: String { defaultCurrency.code }
}
