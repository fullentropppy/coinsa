//
//  PreviewDataDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

enum PreviewTrip: String {
    case turkey
    case southKorea
    case japan

    var localized: String {
        let key = "preview.data.trip.\(rawValue)"
        return String(localized: String.LocalizationValue(key))
    }
}

enum PreviewLocation: String {
    case istanbul
    case seoul
    case busan
    case tokyo
    case kyoto
    case osaka

    var localized: String {
        let key = "preview.data.location.\(rawValue)"
        return String(localized: String.LocalizationValue(key))
    }

    var currencyCode: String {
        switch self {
        case .istanbul:
            return "TRY"
        case .seoul, .busan:
            return "KRW"
        case .tokyo, .kyoto, .osaka:
            return "JPY"
        }
    }

    var exchangeRateToBaseCurrency: Double {
        PreviewCurrency.exchangeRate(from: currencyCode, to: PreviewCurrency.baseCurrencyCode)
    }

    var exchangeRateFromBaseCurrency: Double {
        PreviewCurrency.exchangeRate(from: PreviewCurrency.baseCurrencyCode, to: currencyCode)
    }
}

enum PreviewExpenseComment: String {
    case breakfast
    case lunch
    case streetFood
    case snacks
    case train
    case subway
    case bus
    case taxi
    case museum
    case temple
    case souvenirs
    case clothes
    case pharmacy
    case miscellaneous

    var localized: String {
        let key = "preview.data.expenseComment.\(rawValue)"
        return String(localized: String.LocalizationValue(key))
    }
}

enum PreviewCurrency {
    static var baseCurrencyCode: String {
        String(localized: String.LocalizationValue("preview.data.baseCurrencyCode"))
    }

    fileprivate static let exchangeRates: [String: [String: Double]] = [
        "TRY": ["USD": 0.022, "RUB": 1.8],
        "KRW": ["USD": 0.00075, "RUB": 0.065],
        "JPY": ["USD": 0.007, "RUB": 0.6]
    ]

    fileprivate static func exchangeRate(from: String, to: String) -> Double {
        if let directRate = exchangeRates[from]?[to] {
            return directRate
        }

        if let reverseRate = exchangeRates[to]?[from] {
            return round(1 / reverseRate * 1000) / 1000
        }

        return 1.0
    }
}
