//
//  PreviewDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

// MARK: - Наборы превью-данных

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
    
    var exchangeAdjustmentPercentage: Double {
        switch self {
        case .tokyo, .kyoto, .osaka: 5
        case .saintp: 0
        case .seoul, .busan: 4
        case .istanbul: 3
        }
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

// MARK: - Приватные типы

private enum PreviewCurrency {
    private static let exchangeRates: [String: Double] = [
        Currency.jpy.code: 0.48,
        Currency.rub.code: 1.0,
        Currency.krw.code: 0.05,
        Currency.try.code: 1.73
    ]

    static func exchangeRate(forCode: String) -> Double {
        if let rate = exchangeRates[forCode] {
            rate
        } else {
            1.0
        }
    }
}
