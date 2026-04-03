//
//  PreviewDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

enum PreviewTrip: String {
    case japan = "Япония"
    case russia = "Россия"
    case southKorea = "Южная Корея"
    case turkey = "Турция"
}

enum PreviewLocation: String {
    case tokyo = "Токио"
    case kyoto = "Киото"
    case osaka = "Осака"
    case saintp = "Санкт-Петербург"
    case seoul = "Сеул"
    case busan = "Пусан"
    case istanbul = "Стамбул"

    var currencyCode: String {
        switch self {
        case .tokyo, .kyoto, .osaka: Currency.jpy.code
        case .saintp: Currency.rub.code
        case .seoul, .busan: Currency.krw.code
        case .istanbul: Currency.try.code
        }
    }

    var exchangeRate: Double {
        PreviewCurrency.exchangeRate(forCode: currencyCode)
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
    static let exchangeRates: [String: Double] = [
        Currency.jpy.code: 0.6,
        Currency.rub.code: 1.0,
        Currency.krw.code: 0.065,
        Currency.try.code: 1.8
    ]

    static func exchangeRate(forCode: String) -> Double {
        if let rate = exchangeRates[forCode] {
            return rate
        }

        return 1.0
    }
}
