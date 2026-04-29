//
//  PreviewDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

// MARK: - Наборы данных

enum PreviewTrip: String {
    case japan = "Япония"
    case russia = "Россия"
    case southKorea = "Южная Корея"
    case turkey = "Турция"
    
    var name: String {
        rawValue
    }
    
    var startDate: Date {
        switch self {
        case .japan: Date().adding(months: -14)
        case .russia: Date().adding(months: -2)
        case .southKorea: Date().adding(days: -3)
        case .turkey: Date().adding(months: 3)
        }
    }
    
    var endDate: Date {
        switch self {
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
    
    var startDate: Date {
        switch self {
        case .tokyo: tripData.startDate
        case .kyoto: PreviewLocation.tokyo.endDate
        case .osaka: PreviewLocation.kyoto.endDate
        case .saintp: tripData.startDate
        case .seoul: tripData.startDate
        case .busan: PreviewLocation.seoul.endDate
        case .istanbul: tripData.startDate
        }
    }
    
    var endDate: Date {
        switch self {
        case .tokyo: startDate.adding(days: 6)
        case .kyoto: PreviewLocation.tokyo.endDate.adding(days: 4)
        case .osaka: tripData.endDate
        case .saintp: tripData.endDate
        case .seoul: tripData.startDate.adding(days: 6)
        case .busan: tripData.endDate
        case .istanbul: tripData.endDate
        }
    }

    var majorTimeZone: MajorTimeZone {
        switch self {
        case .tokyo, .kyoto, .osaka, .seoul, .busan: MajorTimeZone.tokyo
        case .saintp, .istanbul: MajorTimeZone.moscow
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

    var rateLocalToBase: Double {
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
    private static let exchangeRates: [Currency: Double] = [
        Currency.jpy: 0.48,
        Currency.rub: 1.0,
        Currency.krw: 0.05,
        Currency.try: 1.73
    ]

    static func exchangeRate(for currency: Currency) -> Double {
        if let rate = exchangeRates[currency] {
            rate
        } else {
            1.0
        }
    }
}
