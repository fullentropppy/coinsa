//
//  PreviewDataDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

enum PreviewTrip: String {
    case turkey = "Турция"
    case southKorea = "Южная Корея"
    case japan = "Япония"
}

enum PreviewLocation: String {
    case istanbul = "Стамбул"
    case seoul = "Сеул"
    case busan = "Пусан"
    case tokyo = "Токио"
    case kyoto = "Киото"
    case osaka = "Осака"

    var currencyCode: String {
        switch self {
        case .istanbul: Currency.try.code
        case .seoul, .busan: Currency.krw.code
        case .tokyo, .kyoto, .osaka: Currency.jpy.code
        }
    }

    var exchangeRateToBaseCurrency: Double {
        PreviewCurrency.exchangeRate(from: currencyCode, to: Currency.defaultCurrencyCode)
    }

    var exchangeRateFromBaseCurrency: Double {
        PreviewCurrency.exchangeRate(from: Currency.defaultCurrencyCode, to: currencyCode)
    }
}

enum PreviewExpenseComment: String {
    case breakfast = "Завтрак"
    case lunch = "Обед"
    case streetFood = "Уличная еда"
    case snacks = "Снэки"
    case train = "Билет на поезд"
    case subway = "Проезд на метро"
    case bus = "Поездка на автобусе"
    case taxi = "Такси"
    case museum = "Посещение музея"
    case temple = "Проход в храм"
    case souvenirs = "Сувениры"
    case clothes = "Одежда"
    case pharmacy = "Лекарства"
    case miscellaneous = "Разное"
}

private enum PreviewCurrency {
    static let exchangeRates: [String: [String: Double]] = [
        Currency.try.code: [Currency.usd.code: 0.022, Currency.rub.code: 1.8],
        Currency.krw.code: [Currency.usd.code: 0.00075, Currency.rub.code: 0.065],
        Currency.jpy.code: [Currency.usd.code: 0.007, Currency.rub.code: 0.6]
    ]

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
