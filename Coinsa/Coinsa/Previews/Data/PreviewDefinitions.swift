//
//  PreviewDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

// MARK: - Наборы данных

/// Предопределенные поездки для превью.
enum PreviewTrip: String {
    case japan = "Япония"
    case russia = "Россия"
    case southKorea = "Южная Корея"
    case turkey = "Турция"
    
    var name: String {
        rawValue
    }
    
    /// Возвращает первый день поездки относительно общего дня генерации.
    /// - Parameter referenceDay: Опорный календарный день без часового пояса.
    func startDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        switch self {
        case .japan: PlainDate(referenceDay.storedDate.adding(months: -14, using: .utc))
        case .russia: PlainDate(referenceDay.storedDate.adding(months: -2, using: .utc))
        case .southKorea: referenceDay.adding(days: -3)
        case .turkey: PlainDate(referenceDay.storedDate.adding(months: 3, using: .utc))
        }
    }

    /// Возвращает последний день поездки относительно общего дня генерации.
    /// - Parameter referenceDay: Опорный календарный день без часового пояса.
    func endDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        let startDate = startDate(relativeTo: referenceDay)
        return switch self {
        case .japan: startDate.adding(days: 14)
        case .russia: startDate
        case .southKorea: startDate.adding(days: 10)
        case .turkey: startDate.adding(days: 7)
        }
    }

    var locationsData: [PreviewLocation] {
        switch self {
        case .japan: [.tokyo, .kyoto, .osaka]
        case .russia: [.saintp]
        case .southKorea: [.seoul, .busan]
        case .turkey: [.istanbul]
        }
    }
}

/// Предопределенные локации для превью.
enum PreviewLocation: String {
    case tokyo = "Токио"
    case kyoto = "Киото"
    case osaka = "Осака"
    case saintp = "Санкт-Петербург"
    case seoul = "Сеул"
    case busan = "Пусан"
    case istanbul = "Стамбул"

    var name: String {
        rawValue
    }
    
    var tripData: PreviewTrip {
        switch self {
        case .tokyo, .kyoto, .osaka: .japan
        case .saintp: .russia
        case .seoul, .busan: .southKorea
        case .istanbul: .turkey
        }
    }
    
    /// Возвращает первый день локации относительно общего дня генерации.
    /// - Parameter referenceDay: Опорный календарный день без часового пояса.
    func startDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        switch self {
        case .tokyo, .saintp, .seoul, .istanbul: tripData.startDate(relativeTo: referenceDay)
        case .kyoto: PreviewLocation.tokyo.endDate(relativeTo: referenceDay)
        case .osaka: PreviewLocation.kyoto.endDate(relativeTo: referenceDay)
        case .busan: PreviewLocation.seoul.endDate(relativeTo: referenceDay)
        }
    }

    /// Возвращает последний день локации относительно общего дня генерации.
    /// - Parameter referenceDay: Опорный календарный день без часового пояса.
    func endDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        switch self {
        case .tokyo: startDate(relativeTo: referenceDay).adding(days: 6)
        case .kyoto: PreviewLocation.tokyo.endDate(relativeTo: referenceDay).adding(days: 4)
        case .seoul: tripData.startDate(relativeTo: referenceDay).adding(days: 6)
        case .osaka, .saintp, .busan, .istanbul: tripData.endDate(relativeTo: referenceDay)
        }
    }

    var timeZoneID: String {
        switch self {
        case .tokyo, .kyoto, .osaka: "Asia/Tokyo"
        case .saintp: "Europe/Moscow"
        case .seoul, .busan: "Asia/Seoul"
        case .istanbul: "Europe/Istanbul"
        }
    }
    
    var currency: Currency {
        switch self {
        case .tokyo, .kyoto, .osaka: Currency.jpy
        case .saintp: Currency.rub
        case .seoul, .busan: Currency.krw
        case .istanbul: Currency.try
        }
    }

    var rateLocationToHome: Double {
        PreviewCurrency.exchangeRate(for: currency)
    }
    
    var exchangeAdjustment: Double {
        switch self {
        case .tokyo, .kyoto, .osaka: 5
        case .saintp: 0
        case .seoul, .busan: 4
        case .istanbul: 3
        }
    }
    
    var budget: Double {
        switch self {
        case .tokyo: 82740
        case .kyoto: 62500
        case .osaka: 50500
        case .saintp: 13500
        case .seoul: 115200
        case .busan: 33200
        case .istanbul: 43800
        }
    }
    
    var centerPoint: Coordinate {
        switch self {
        case .tokyo: Coordinate(latitude: 35.6762, longitude: 139.6503, horizontalAccuracy: 15)
        case .kyoto: Coordinate(latitude: 35.0116, longitude: 135.7681, horizontalAccuracy: 15)
        case .osaka: Coordinate(latitude: 34.6937, longitude: 135.5023, horizontalAccuracy: 15)
        case .saintp: Coordinate(latitude: 59.9311, longitude: 30.3609, horizontalAccuracy: 15)
        case .seoul: Coordinate(latitude: 37.5665, longitude: 126.9780, horizontalAccuracy: 15)
        case .busan: Coordinate(latitude: 35.1796, longitude: 129.0756, horizontalAccuracy: 15)
        case .istanbul: Coordinate(latitude: 41.0082, longitude: 28.9784, horizontalAccuracy: 15)
        }
    }
}

/// Предопределенные комментарии к тратам для превью.
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

/// Внутренний помощник для получения курсов валют для превью.
private enum PreviewCurrency {
    /// Фиксированные курсы валют к RUB.
    private static let exchangeRates: [Currency: Double] = [
        Currency.jpy: 0.48,
        Currency.rub: 1.0,
        Currency.krw: 0.05,
        Currency.try: 1.73
    ]

    /// Возвращает курс обмена для указанной валюты.
    /// - Parameter currency: Валюта.
    /// - Returns: Курс к RUB.
    static func exchangeRate(for currency: Currency) -> Double {
        if let rate = exchangeRates[currency] {
            rate
        } else {
            1.0
        }
    }
}
