//
//  PreviewDefinitions.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

// MARK: - Поездки

/// Синтетические маршруты с датами относительно единого дня генерации.
enum PreviewTrip: String, CaseIterable {
    case balkans = "Балканы и Турция"
    case asia = "Азия"
    case sergievPosad = "Подмосковье"
    case saintPetersburg = "Санкт-Петербург"
    case southAmerica = "Южная Америка"

    var name: String { rawValue }

    /// Независимый округленный план общих трат в рублях с запасом или небольшим перерасходом.
    var generalExpensesBudget: Double {
        switch self {
        case .balkans: 40000
        case .asia: 55000
        case .southAmerica: 100000
        case .sergievPosad, .saintPetersburg: 0
        }
    }

    /// Возвращает начало маршрута относительно опорного календарного дня.
    /// - Parameter referenceDay: Единый день генерации без часового пояса.
    func startDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        switch self {
        case .balkans: referenceDay.adding(days: -13)
        case .asia: PlainDate(referenceDay.storedDate.adding(months: -12, using: .utc))
        case .sergievPosad: PlainDate(referenceDay.storedDate.adding(months: -1, using: .utc))
        case .saintPetersburg: PlainDate(referenceDay.storedDate.adding(months: -4, using: .utc))
        case .southAmerica: PlainDate(referenceDay.storedDate.adding(months: 6, using: .utc))
        }
    }

    /// Возвращает последний включенный день маршрута.
    /// - Parameter referenceDay: Единый день генерации без часового пояса.
    func endDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        guard let last = locationsData.last else { return startDate(relativeTo: referenceDay) }
        return last.endDate(relativeTo: referenceDay)
    }

    var locationsData: [PreviewLocation] {
        switch self {
        case .balkans: [.kotor, .sarajevo, .belgrade, .noviSad, .istanbul]
        case .asia: [.hongKong, .hanoi, .bangkok, .phuket, .kualaLumpur]
        case .sergievPosad: [.sergievPosad]
        case .saintPetersburg: [.saintPetersburg]
        case .southAmerica: [.saoPaulo, .rioDeJaneiro, .buenosAires, .lima, .bogota]
        }
    }
}

// MARK: - Локации

/// Параметры локаций; бюджеты и курсы заданы в рублях домашней валюты.
enum PreviewLocation: String, CaseIterable {
    case kotor = "Котор"
    case sarajevo = "Сараево"
    case belgrade = "Белград"
    case noviSad = "Нови-Сад"
    case istanbul = "Стамбул"
    case hongKong = "Гонконг"
    case hanoi = "Ханой"
    case bangkok = "Бангкок"
    case phuket = "Пхукет"
    case kualaLumpur = "Куала-Лумпур"
    case sergievPosad = "Сергиев Посад"
    case saintPetersburg = "Санкт-Петербург"
    case saoPaulo = "Сан-Паулу"
    case rioDeJaneiro = "Рио-де-Жанейро"
    case buenosAires = "Буэнос-Айрес"
    case lima = "Лима"
    case bogota = "Богота"

    var name: String { rawValue }

    var tripData: PreviewTrip {
        switch self {
        case .kotor, .sarajevo, .belgrade, .noviSad, .istanbul: .balkans
        case .hongKong, .hanoi, .bangkok, .phuket, .kualaLumpur: .asia
        case .sergievPosad: .sergievPosad
        case .saintPetersburg: .saintPetersburg
        case .saoPaulo, .rioDeJaneiro, .buenosAires, .lima, .bogota: .southAmerica
        }
    }

    /// Возвращает начало локации без пересечений с соседними этапами маршрута.
    /// - Parameter referenceDay: Единый день генерации без часового пояса.
    func startDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        tripData.startDate(relativeTo: referenceDay).adding(days: schedule.offset)
    }

    /// Возвращает последний включенный день пребывания в локации.
    /// - Parameter referenceDay: Единый день генерации без часового пояса.
    func endDate(relativeTo referenceDay: PlainDate) -> PlainDate {
        startDate(relativeTo: referenceDay).adding(days: schedule.days - 1)
    }

    private var schedule: (offset: Int, days: Int) {
        switch self {
        case .kotor: (0, 4)
        case .sarajevo: (4, 4)
        case .belgrade: (8, 8)
        case .noviSad: (16, 3)
        case .istanbul: (19, 5)
        case .hongKong: (0, 4)
        case .hanoi: (4, 4)
        case .bangkok: (8, 5)
        case .phuket: (13, 5)
        case .kualaLumpur: (18, 4)
        case .sergievPosad: (0, 1)
        case .saintPetersburg: (0, 4)
        case .saoPaulo: (0, 4)
        case .rioDeJaneiro: (4, 5)
        case .buenosAires: (9, 5)
        case .lima: (14, 4)
        case .bogota: (18, 4)
        }
    }

    var currency: Currency {
        switch self {
        case .kotor: .eur
        case .sarajevo: .bam
        case .belgrade: .rsd
        case .noviSad: .rsd
        case .istanbul: .try
        case .hongKong: .hkd
        case .hanoi: .vnd
        case .bangkok: .thb
        case .phuket: .thb
        case .kualaLumpur: .myr
        case .sergievPosad: .rub
        case .saintPetersburg: .rub
        case .saoPaulo: .brl
        case .rioDeJaneiro: .brl
        case .buenosAires: .ars
        case .lima: .pen
        case .bogota: .cop
        }
    }

    var rateLocationToHome: Double {
        switch self {
        case .kotor: 100
        case .sarajevo: 51
        case .belgrade: 0.85
        case .noviSad: 0.85
        case .istanbul: 2.3
        case .hongKong: 11.5
        case .hanoi: 0.0036
        case .bangkok: 2.6
        case .phuket: 2.6
        case .kualaLumpur: 20
        case .sergievPosad: 1
        case .saintPetersburg: 1
        case .saoPaulo: 17
        case .rioDeJaneiro: 17
        case .buenosAires: 0.075
        case .lima: 24
        case .bogota: 0.022
        }
    }

    var budget: Double {
        switch self {
        case .kotor: 85000
        case .sarajevo: 38000
        case .belgrade: 98000
        case .noviSad: 26000
        case .istanbul: 65000
        case .hongKong: 78000
        case .hanoi: 31500
        case .bangkok: 52000
        case .phuket: 62000
        case .kualaLumpur: 45000
        case .sergievPosad: 10000
        case .saintPetersburg: 43000
        case .saoPaulo: 145000
        case .rioDeJaneiro: 90000
        case .buenosAires: 105000
        case .lima: 85000
        case .bogota: 95000
        }
    }

    var exchangeAdjustment: Double {
        switch self {
        case .kotor: 2
        case .sarajevo: 2
        case .belgrade: 2.5
        case .noviSad: 2.5
        case .istanbul: 3
        case .hongKong: 2
        case .hanoi: 2
        case .bangkok: 2.5
        case .phuket: 2.5
        case .kualaLumpur: 2
        case .sergievPosad: 0
        case .saintPetersburg: 0
        case .saoPaulo: 3
        case .rioDeJaneiro: 3
        case .buenosAires: 3
        case .lima: 3
        case .bogota: 3
        }
    }

    var timeZoneID: String {
        switch self {
        case .kotor: "Europe/Podgorica"
        case .sarajevo: "Europe/Sarajevo"
        case .belgrade: "Europe/Belgrade"
        case .noviSad: "Europe/Belgrade"
        case .istanbul: "Europe/Istanbul"
        case .hongKong: "Asia/Hong_Kong"
        case .hanoi: "Asia/Ho_Chi_Minh"
        case .bangkok: "Asia/Bangkok"
        case .phuket: "Asia/Bangkok"
        case .kualaLumpur: "Asia/Kuala_Lumpur"
        case .sergievPosad: "Europe/Moscow"
        case .saintPetersburg: "Europe/Moscow"
        case .saoPaulo: "America/Sao_Paulo"
        case .rioDeJaneiro: "America/Sao_Paulo"
        case .buenosAires: "America/Argentina/Buenos_Aires"
        case .lima: "America/Lima"
        case .bogota: "America/Bogota"
        }
    }

    var centerPoint: Coordinate {
        switch self {
        case .kotor: Coordinate(latitude: 42.4247, longitude: 18.7712, horizontalAccuracy: 25)
        case .sarajevo: Coordinate(latitude: 43.8591, longitude: 18.4312, horizontalAccuracy: 25)
        case .belgrade: Coordinate(latitude: 44.8178, longitude: 20.4601, horizontalAccuracy: 25)
        case .noviSad: Coordinate(latitude: 45.2551, longitude: 19.8452, horizontalAccuracy: 25)
        case .istanbul: Coordinate(latitude: 41.0086, longitude: 28.9802, horizontalAccuracy: 25)
        case .hongKong: Coordinate(latitude: 22.2987, longitude: 114.1722, horizontalAccuracy: 25)
        case .hanoi: Coordinate(latitude: 21.0288, longitude: 105.852, horizontalAccuracy: 25)
        case .bangkok: Coordinate(latitude: 13.7462, longitude: 100.5347, horizontalAccuracy: 25)
        case .phuket: Coordinate(latitude: 7.883, longitude: 98.388, horizontalAccuracy: 25)
        case .kualaLumpur: Coordinate(latitude: 3.1478, longitude: 101.6953, horizontalAccuracy: 25)
        case .sergievPosad: Coordinate(latitude: 56.3100, longitude: 38.1306, horizontalAccuracy: 25)
        case .saintPetersburg: Coordinate(latitude: 59.9343, longitude: 30.3351, horizontalAccuracy: 25)
        case .saoPaulo: Coordinate(latitude: -23.5505, longitude: -46.6333, horizontalAccuracy: 25)
        case .rioDeJaneiro: Coordinate(latitude: -22.9068, longitude: -43.1729, horizontalAccuracy: 25)
        case .buenosAires: Coordinate(latitude: -34.6037, longitude: -58.3816, horizontalAccuracy: 25)
        case .lima: Coordinate(latitude: -12.1211, longitude: -77.0305, horizontalAccuracy: 25)
        case .bogota: Coordinate(latitude: 4.5981, longitude: -74.0758, horizontalAccuracy: 25)
        }
    }
}

// MARK: - Условные курсы

/// Фиксированные синтетические курсы; внешние сервисы при генерации не используются.
enum PreviewExchangeRates {
    /// Возвращает количество рублей за единицу валюты траты.
    /// - Parameter currency: Валюта исходной суммы.
    static func toHome(for currency: Currency) -> Double {
        guard let rate = availableRateToHome(for: currency) else {
            preconditionFailure("Missing synthetic exchange rate for \(currency.code)")
        }
        return rate
    }

    /// Возвращает синтетический курс к рублю, если он определен для превью.
    /// - Parameter currency: Валюта исходной суммы.
    static func availableRateToHome(for currency: Currency) -> Double? {
        switch currency {
        case .rub: 1
        case .eur: 100
        case .usd: 92
        case .bam: 51
        case .rsd: 0.85
        case .try: 2.3
        case .hkd: 11.5
        case .vnd: 0.0036
        case .thb: 2.6
        case .myr: 20
        case .brl: 17
        case .ars: 0.075
        case .pen: 24
        case .cop: 0.022
        default: nil
        }
    }
}
