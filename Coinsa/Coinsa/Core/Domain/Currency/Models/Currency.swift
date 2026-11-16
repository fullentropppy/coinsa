//
//  Currency.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

/// Трехбуквенные коды ISO 4217 валют.
enum Currency: String, Codable, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case aed = "AED"
    case amd = "AMD"
    case ars = "ARS"
    case aud = "AUD"
    case azn = "AZN"
    case bam = "BAM"
    case brl = "BRL"
    case byn = "BYN"
    case cad = "CAD"
    case chf = "CHF"
    case cny = "CNY"
    case cop = "COP"
    case czk = "CZK"
    case dkk = "DKK"
    case egp = "EGP"
    case eur = "EUR"
    case gbp = "GBP"
    case gel = "GEL"
    case hkd = "HKD"
    case huf = "HUF"
    case idr = "IDR"
    case ils = "ILS"
    case inr = "INR"
    case isk = "ISK"
    case jod = "JOD"
    case jpy = "JPY"
    case kes = "KES"
    case kgs = "KGS"
    case khr = "KHR"
    case krw = "KRW"
    case kzt = "KZT"
    case lak = "LAK"
    case lkr = "LKR"
    case mad = "MAD"
    case mop = "MOP"
    case mur = "MUR"
    case mvr = "MVR"
    case mxn = "MXN"
    case myr = "MYR"
    case nok = "NOK"
    case nzd = "NZD"
    case omr = "OMR"
    case pen = "PEN"
    case php = "PHP"
    case pln = "PLN"
    case qar = "QAR"
    case ron = "RON"
    case rsd = "RSD"
    case rub = "RUB"
    case sar = "SAR"
    case scr = "SCR"
    case sek = "SEK"
    case sgd = "SGD"
    case thb = "THB"
    case tjs = "TJS"
    case tnd = "TND"
    case `try` = "TRY"
    case twd = "TWD"
    case tzs = "TZS"
    case uah = "UAH"
    case usd = "USD"
    case uzs = "UZS"
    case vnd = "VND"
    case zar = "ZAR"

    // MARK: - Основные свойства
    
    var id: String { rawValue }
    var code: String { rawValue }
}
