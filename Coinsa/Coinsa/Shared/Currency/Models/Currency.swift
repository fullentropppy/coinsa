//
//  Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    // MARK: - Cases

    case aed = "AED"
    case amd = "AMD"
    case azn = "AZN"
    case byn = "BYN"
    case cny = "CNY"
    case eur = "EUR"
    case gbp = "GBP"
    case gel = "GEL"
    case hkd = "HKD"
    case idr = "IDR"
    case jpy = "JPY"
    case krw = "KRW"
    case kzt = "KZT"
    case mop = "MOP"
    case myr = "MYR"
    case rub = "RUB"
    case sgd = "SGD"
    case thb = "THB"
    case `try` = "TRY"
    case usd = "USD"
    case uzs = "UZS"
    case vnd = "VND"

    // MARK: - Stored Properties
    
    var id: String { rawValue }
    var code: String { rawValue }
    
    // MARK: - Computed Properties
    
    static var defaultOption: Currency {
        Currency.rub
    }
    
    static var defaultCurrencyCode: String {
        defaultOption.code
    }

    // MARK: - Public Methods
    
    static func from(_ code: String) -> Currency {
        Currency(rawValue: code.uppercased()) ?? .defaultOption
    }
}
