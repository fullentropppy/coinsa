//
//  Currency+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

extension Currency {
    // MARK: - Свойства

    /// Валюта по умолчанию (российский рубль).
    static var defaultValue: Currency { Currency.rub }
    
    /// Код валюты по умолчанию ("RUB").
    static var defaultCode: String { defaultValue.code }
}
