//
//  Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

enum Currency: String, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case aed = "AED"
    case byn = "BYN"
    case cny = "CNY"
    case eur = "EUR"
    case jpy = "JPY"
    case krw = "KRW"
    case kzt = "KZT"
    case rub = "RUB"
    case `try` = "TRY"
    case usd = "USD"

    // MARK: - Базовые свойства
    
    var id: String { rawValue }
    var code: String { rawValue }
}
