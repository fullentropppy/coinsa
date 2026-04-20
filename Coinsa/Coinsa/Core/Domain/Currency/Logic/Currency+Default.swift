//
//  Currency+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

extension Currency {
    static var defaultValue: Currency { Currency.rub }
    static var defaultCode: String { defaultValue.code }
}
