//
//  Currency+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

extension Currency: LocalizationKeyProviding {
    static var localizationKeyPrefix: String {
        "currency.name"
    }
}
