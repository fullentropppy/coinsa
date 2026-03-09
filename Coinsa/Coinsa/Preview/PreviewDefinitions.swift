//
//  PreviewDataDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

enum PreviewTrip: String {
    // MARK: - PreviewTrip. Cases
    
    case turkey = "preview.data.trip.turkey"
    case southKorea = "preview.data.trip.southKorea"
    case japan = "preview.data.trip.japan"

    // MARK: - PreviewTrip. Computed Properties
    
    var localizedDisplayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}

enum PreviewLocation: String {
    // MARK: - PreviewLocation. Cases
    
    case istanbul = "preview.data.location.istanbul"
    case seoul = "preview.data.location.seoul"
    case busan = "preview.data.location.busan"
    case tokyo = "preview.data.location.tokyo"
    case kyoto = "preview.data.location.kyoto"
    case osaka = "preview.data.location.osaka"

    // MARK: - PreviewLocation. Computed Properties
    
    var localizedDisplayName: String {
        return String(localized: String.LocalizationValue(rawValue))
    }

    var currencyCode: String {
        switch self {
        case .istanbul:
            return CurrencyOption.try.code
        case .seoul, .busan:
            return CurrencyOption.krw.code
        case .tokyo, .kyoto, .osaka:
            return CurrencyOption.jpy.code
        }
    }

    var exchangeRateToBaseCurrency: Double {
        PreviewCurrency.exchangeRate(from: currencyCode, to: CurrencyOption.baseCurrencyCode)
    }

    var exchangeRateFromBaseCurrency: Double {
        PreviewCurrency.exchangeRate(from: CurrencyOption.baseCurrencyCode, to: currencyCode)
    }
}

enum PreviewExpenseComment: String {
    // MARK: - PreviewExpenseComment. Cases
    
    case breakfast = "preview.data.expenseComment.breakfast"
    case lunch  = "preview.data.expenseComment.lunch"
    case streetFood  = "preview.data.expenseComment.streetFood"
    case snacks = "preview.data.expenseComment.snacks"
    case train = "preview.data.expenseComment.train"
    case subway = "preview.data.expenseComment.subway"
    case bus = "preview.data.expenseComment.bus"
    case taxi = "preview.data.expenseComment.taxi"
    case museum = "preview.data.expenseComment.museum"
    case temple = "preview.data.expenseComment.temple"
    case souvenirs = "preview.data.expenseComment.souvenirs"
    case clothes = "preview.data.expenseComment.clothes"
    case pharmacy = "preview.data.expenseComment.pharmacy"
    case miscellaneous = "preview.data.expenseComment.miscellaneous"

    // MARK: - PreviewExpenseComment. Computed Properties
    
    var localizedDisplayName: String {
        return String(localized: String.LocalizationValue(rawValue))
    }
}

private enum PreviewCurrency {
    // MARK: - PreviewCurrency. Stored Properties
    
    static let exchangeRates: [String: [String: Double]] = [
        CurrencyOption.try.code: [CurrencyOption.usd.code: 0.022, CurrencyOption.rub.code: 1.8],
        CurrencyOption.krw.code: [CurrencyOption.usd.code: 0.00075, CurrencyOption.rub.code: 0.065],
        CurrencyOption.jpy.code: [CurrencyOption.usd.code: 0.007, CurrencyOption.rub.code: 0.6]
    ]

    // MARK: - PreviewCurrency. Public Methods
    
    static func exchangeRate(from: String, to: String) -> Double {
        if let directRate = exchangeRates[from]?[to] {
            return directRate
        }

        if let reverseRate = exchangeRates[to]?[from] {
            return round(1 / reverseRate * 1000) / 1000
        }

        return 1.0
    }
}
