//
//  Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

enum Currency: String, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case aed = "AED"
    case amd = "AMD"
    case ars = "ARS"
    case aud = "AUD"
    case azn = "AZN"
    case bgn = "BGN"
    case brl = "BRL"
    case byn = "BYN"
    case cad = "CAD"
    case cny = "CNY"
    case cop = "COP"
    case czk = "CZK"
    case dkk = "DKK"
    case egp = "EGP"
    case eur = "EUR"
    case gbp = "GBP"
    case gel = "GEL"
    case hkd = "HKD"
    case hrk = "HRK"
    case huf = "HUF"
    case idr = "IDR"
    case ils = "ILS"
    case inr = "INR"
    case jpy = "JPY"
    case krw = "KRW"
    case kzt = "KZT"
    case mad = "MAD"
    case mop = "MOP"
    case mxn = "MXN"
    case myr = "MYR"
    case nok = "NOK"
    case php = "PHP"
    case pln = "PLN"
    case qar = "QAR"
    case rub = "RUB"
    case sar = "SAR"
    case sek = "SEK"
    case sgd = "SGD"
    case thb = "THB"
    case `try` = "TRY"
    case usd = "USD"
    case uzs = "UZS"
    case vnd = "VND"
    case zar = "ZAR"

    // MARK: - Базовые свойства
    
    var id: String { rawValue }
    var code: String { rawValue }
}
