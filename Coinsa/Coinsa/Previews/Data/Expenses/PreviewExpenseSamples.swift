//
//  PreviewExpenseSamples.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import Foundation

/// Детерминированные покупки по дневным маршрутам и предварительные оплаты.
enum PreviewExpenseSamples {
    /// Создает историю до опорного дня и четыре фиксированные сегодняшние траты.
    /// - Parameters:
    ///   - location: Локация с географией, дневными маршрутами и условными ценами.
    ///   - referenceDay: Единый календарный день; сегодняшние покупки не зависят от часа генерации.
    static func makeSamples(
        for location: PreviewLocation,
        referenceDay: PlainDate
    ) -> [ExpensePreviewSample] {
        let start = location.startDate(relativeTo: referenceDay)
        guard start <= referenceDay else {
            return upcomingPayments(for: location, referenceDay: referenceDay)
        }
        let end = min(location.endDate(relativeTo: referenceDay), referenceDay)
        let places = PreviewExpenseCatalog.places(for: location)
        let prices = PreviewExpenseCatalog.prices(for: location)
        let routes = PreviewExpenseCatalog.dailyRoutes(for: location)
        guard !places.isEmpty, prices.count == 7 else { return [] }

        var samples = advancePayments(for: location, referenceDay: referenceDay, nightlyPrice: prices[6])
        for day in 0...end.days(from: start) {
            let date = start.adding(days: day)
            if date == referenceDay {
                samples += todayPurchases(for: location, on: referenceDay, places: places)
            } else {
                samples += dailyPurchases(
                    for: location,
                    on: date,
                    dayIndex: day,
                    placeIndices: routes[day],
                    places: places,
                    prices: prices
                )
            }
        }
        for (index, activity) in PreviewExpenseCatalog.activities(for: location).enumerated() {
            let date = start.adding(days: activity.dayOffset)
            guard date < referenceDay else { continue }
            let place = places[activity.placeIndex]
            samples.append(ExpensePreviewSample(
                date: date.storedDate.adding(minutes: activity.minuteOfDay, using: .utc),
                amount: activity.amount,
                currency: activity.currency ?? location.currency,
                timeZoneID: activity.timeZoneID ?? location.timeZoneID,
                rateVariation: rateVariation(at: index),
                paymentMethod: [.donation, .tips, .otherFood, .otherMiscellaneous, .laundry, .beach].contains(activity.subcategory)
                    ? .cash : (index % 3 == 0 ? .cash : .card),
                subcategory: activity.subcategory,
                comment: activity.comment,
                coordinate: activity.coordinate ?? Coordinate(
                    latitude: place.latitude,
                    longitude: place.longitude,
                    horizontalAccuracy: 25
                )
            ))
        }
        return samples.sorted { $0.date < $1.date }
    }
}

// MARK: - Покупки на дневном маршруте

private extension PreviewExpenseSamples {
    static func dailyPurchases(
        for location: PreviewLocation,
        on date: PlainDate,
        dayIndex: Int,
        placeIndices: [Int],
        places: [PreviewExpensePlace],
        prices: [Double]
    ) -> [ExpensePreviewSample] {
        let subcategories: [ExpenseSubcategory] = [
            .breakfast, location == .belgrade ? .taxi : .publicTransport, .lunch, .snack, .dinner, .groceries
        ]
        let minutes = [8 * 60 + 15, 9 * 60 + 15, 13 * 60, 16 * 60 + 15, 19 * 60 + 15, location == .sergievPosad ? 21 * 60 : 20 * 60 + 30]
        let descriptions = [
            "Завтрак и кофе", location == .belgrade ? "Такси до района прогулки" : "Проезд по городу",
            "Обед во время прогулки", "Кофе и местная выпечка", "Ужин после прогулки", "Вода и фрукты на завтра"
        ]
        return subcategories.enumerated().compactMap { slot, subcategory in
            guard !(location == .phuket && dayIndex == 0 && slot == 1) else { return nil }
            let index = dayIndex * 6 + slot
            let place = places[placeIndices[slot]]
            let paymentMethod: PaymentMethod = index % 5 < 3 ? .card : .cash
            let amount = dailyAmount(prices[slot], in: location.currency, slot: slot, index: index, paymentMethod: paymentMethod)
            let hasComment = (index * 37 + 13) % 100 < 40
            let coordinate = index % 7 == 0 ? nil : Coordinate(
                latitude: place.latitude,
                longitude: place.longitude,
                horizontalAccuracy: 25
            )
            return ExpensePreviewSample(
                date: date.storedDate.adding(minutes: minutes[slot], using: .utc),
                amount: amount,
                currency: location.currency,
                timeZoneID: location.timeZoneID,
                rateVariation: rateVariation(at: index),
                paymentMethod: paymentMethod,
                subcategory: subcategory,
                comment: hasComment ? "\(descriptions[slot]). \(place.name)" : nil,
                coordinate: coordinate
            )
        }
    }

    static func dailyAmount(
        _ price: Double,
        in currency: Currency,
        slot: Int,
        index: Int,
        paymentMethod: PaymentMethod
    ) -> Double {
        guard slot != 1 else { return price }
        let variation = 1 + Double((index * 7) % 5 - 2) * 0.05
        let amount = price * variation
        if currency == .vnd {
            return (amount / 500).rounded(.toNearestOrEven) * 500
        }
        if paymentMethod == .cash {
            let step: Double = [.eur, .bam, .myr, .hkd].contains(currency) ? 0.1 : 1
            return (amount / step).rounded(.toNearestOrEven) * step
        }
        let cents = [0.15, 0.45, 0.79, 0.95][index % 4]
        return (amount.rounded(.down) + cents).rounded(to: 2)
    }

    static func todayPurchases(
        for location: PreviewLocation,
        on date: PlainDate,
        places: [PreviewExpensePlace]
    ) -> [ExpensePreviewSample] {
        let breakfastPlace = places[5]
        let lunchPlace = places[1]
        let purchases: [(minute: Int, amount: Double, subcategory: ExpenseSubcategory, comment: String?, coordinate: Coordinate?)] = [
            (8 * 60 + 20, 684.50, .breakfast, "Завтрак и кофе перед прогулкой по Звездаре",
             Coordinate(latitude: breakfastPlace.latitude, longitude: breakfastPlace.longitude, horizontalAccuracy: 25)),
            (10 * 60 + 10, 3250, .souvenirs, "Запланированная покупка подарков, вне дневных трат", nil),
            (13 * 60 + 15, 1438.90, .lunch, "Обед в небольшом кафе на Врачаре",
             Coordinate(latitude: lunchPlace.latitude, longitude: lunchPlace.longitude, horizontalAccuracy: 25)),
            (15 * 60 + 20, 812.45, .taxi, nil,
             Coordinate(latitude: 44.8108, longitude: 20.4687, horizontalAccuracy: 25))
        ]
        return purchases.enumerated().map { index, purchase in
            ExpensePreviewSample(
                date: date.storedDate.adding(minutes: purchase.minute, using: .utc),
                amount: purchase.amount,
                currency: location.currency,
                timeZoneID: location.timeZoneID,
                rateVariation: rateVariation(at: index),
                paymentMethod: index == 1 ? .cash : .card,
                subcategory: purchase.subcategory,
                comment: purchase.comment,
                coordinate: purchase.coordinate,
                isExcludedFromDailySpending: index == 1
            )
        }
    }

    static func rateVariation(at index: Int) -> Double {
        index % 2 == 0 ? 1 : 1 + Double(index % 7 - 3) * 0.008
    }
}

// MARK: - Покупки до начала локаций

private extension PreviewExpenseSamples {
    static func advancePayments(
        for location: PreviewLocation,
        referenceDay: PlainDate,
        nightlyPrice: Double
    ) -> [ExpensePreviewSample] {
        let start = location.startDate(relativeTo: referenceDay)
        let days = location.endDate(relativeTo: referenceDay).days(from: start) + 1
        let tripStart = location.tripData.startDate(relativeTo: referenceDay)
        let index = location.tripData.locationsData.firstIndex(of: location) ?? 0
        var samples: [ExpensePreviewSample] = []
        if nightlyPrice > 0 {
            let currency: Currency = switch location {
            case .hongKong, .hanoi, .phuket: .usd
            case .belgrade: .eur
            default: location.currency
            }
            let localAmount = nightlyPrice * Double(days)
            let amount = currency == location.currency ? localAmount
                : (localAmount * location.rateLocationToHome / PreviewExchangeRates.toHome(for: currency)).rounded(to: 2)
            samples.append(homePayment(
                on: tripStart.adding(days: -40 + index * 3),
                amount: amount,
                currency: currency,
                subcategory: location == .saintPetersburg ? .accommodationRental : .hotel,
                comment: "Предоплата: \(location == .saintPetersburg ? "квартира" : "отель"), \(location.name), весь срок проживания"
            ))
        }
        let ticket: (Double, Currency, ExpenseSubcategory, String)? = switch location {
        case .kotor: (21800, .rub, .plane, "Билет до Тивата, багаж включен")
        case .sarajevo: (32, .eur, .intercityBus, "Билет на автобус Котор — Сараево")
        case .belgrade: (2900, .rsd, .intercityBus, "Билет на автобус Сараево — Белград")
        case .hongKong: (28600, .rub, .plane, "Билет Москва — Гонконг с пересадкой")
        case .hanoi: (84.70, .usd, .plane, "Билет Гонконг — Ханой, куплен до поездки")
        case .bangkok: (95.35, .usd, .plane, "Билет Ханой — Бангкок, куплен до поездки")
        case .phuket: (58.20, .usd, .plane, "Билет Бангкок — Пхукет, куплен до поездки")
        case .kualaLumpur: (68.40, .usd, .plane, "Билет Пхукет — Куала-Лумпур, куплен до поездки")
        default: nil
        }
        if let ticket {
            samples.append(homePayment(
                on: tripStart.adding(days: -35 + index * 3),
                amount: ticket.0,
                currency: ticket.1,
                subcategory: ticket.2,
                comment: ticket.3
            ))
        }
        if location == .kotor || location == .hongKong {
            samples.append(homePayment(
                on: tripStart.adding(days: -34),
                amount: location == .kotor ? 1850 : 2700,
                currency: .rub,
                subcategory: .healthInsurance,
                comment: "Страховка на весь маршрут"
            ))
        }
        return samples
    }

    static func upcomingPayments(for location: PreviewLocation, referenceDay: PlainDate) -> [ExpensePreviewSample] {
        let places = PreviewExpenseCatalog.places(for: .belgrade)
        switch location {
        case .noviSad:
            return [
                bookingFromBelgrade(on: referenceDay.adding(days: -3), minute: 13 * 60 + 10, amount: 92.70, currency: .eur, subcategory: .hotel, comment: "Предоплата отеля в Нови-Саде на три ночи", place: places[1]),
                bookingFromBelgrade(on: referenceDay.adding(days: -2), minute: 13 * 60 + 5, amount: 612.50, currency: .rsd, subcategory: .train, comment: "Билет Белград — Нови-Сад на предстоящий переезд", place: places[3])
            ]
        case .istanbul:
            return [
                bookingFromBelgrade(on: referenceDay.adding(days: -4), minute: 13 * 60 + 25, amount: 147.85, currency: .eur, subcategory: .plane, comment: "Билет Белград — Стамбул после возвращения из Нови-Сада", place: places[2])
            ]
        case .saoPaulo:
            return [
                homePayment(on: referenceDay.adding(days: -50), amount: 995.75, currency: .usd, subcategory: .plane, comment: "Билет до Сан-Паулу с пересадкой, поездка через полгода"),
                homePayment(on: referenceDay.adding(days: -46), amount: 228.45, currency: .usd, subcategory: .hotel, comment: "Предоплата отеля в Сан-Паулу на четыре ночи")
            ]
        case .rioDeJaneiro:
            return [homePayment(on: referenceDay.adding(days: -44), amount: 1398.90, currency: .brl, subcategory: .hotel, comment: "Предоплата отеля в Рио-де-Жанейро на пять ночей")]
        case .buenosAires:
            return [homePayment(on: referenceDay.adding(days: -42), amount: 287.40, currency: .usd, subcategory: .accommodationRental, comment: "Предоплата квартиры в Буэнос-Айресе на пять ночей")]
        default:
            return []
        }
    }

    static func homePayment(
        on date: PlainDate,
        amount: Double,
        currency: Currency,
        subcategory: ExpenseSubcategory,
        comment: String
    ) -> ExpensePreviewSample {
        ExpensePreviewSample(
            date: date.storedDate.adding(hours: 21, minutes: 35, using: .utc),
            amount: amount,
            currency: currency,
            timeZoneID: "Europe/Moscow",
            rateVariation: 0.976,
            paymentMethod: .card,
            subcategory: subcategory,
            comment: comment,
            coordinate: Coordinate(latitude: 55.757, longitude: 37.586, horizontalAccuracy: 40)
        )
    }

    static func bookingFromBelgrade(
        on date: PlainDate,
        minute: Int,
        amount: Double,
        currency: Currency,
        subcategory: ExpenseSubcategory,
        comment: String,
        place: PreviewExpensePlace
    ) -> ExpensePreviewSample {
        ExpensePreviewSample(
            date: date.storedDate.adding(minutes: minute, using: .utc),
            amount: amount,
            currency: currency,
            timeZoneID: "Europe/Belgrade",
            rateVariation: 1.016,
            paymentMethod: .card,
            subcategory: subcategory,
            comment: comment,
            coordinate: Coordinate(latitude: place.latitude, longitude: place.longitude, horizontalAccuracy: 25)
        )
    }
}
