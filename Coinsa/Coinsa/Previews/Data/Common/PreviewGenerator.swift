//
//  PreviewGenerator.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

// MARK: - Публичные типы

/// Сценарии генерации синтетических данных для превью и отладочного наполнения.
enum PreviewScenario: String, CaseIterable {
    case balkans
    case asia
    case sergievPosad
    case saintPetersburg
    case russia
    case southAmerica
    case all
}

/// Настройки включения связанных данных при генерации.
struct PreviewOptions {
    var includeTrips = true
    var includeLocations = true
    var includeExpenses = true
    var includeGeneralExpenses = true
}

// MARK: - Генератор превью-данных

/// Общий генератор синтетических моделей для SwiftUI previews и демоданных.
enum PreviewGenerator {
    /// Создает поездки с общей опорной датой и согласованными связанными записями.
    /// - Parameters:
    ///   - scenario: Сценарий генерации.
    ///   - options: Настройки включения подчиненных объектов.
    ///   - referenceDate: Общий момент генерации; календарный день определяется в текущем поясе.
    static func makeTrips(
        for scenario: PreviewScenario,
        options: PreviewOptions,
        referenceDate: Date = .now
    ) -> [Trip] {
        guard options.includeTrips else { return [] }
        let referenceDay = PlainDate(referenceDate, using: .current)
        let trips: [PreviewTrip] = switch scenario {
        case .balkans: [.balkans]
        case .asia: [.asia]
        case .sergievPosad: [.sergievPosad]
        case .saintPetersburg: [.saintPetersburg]
        case .russia: [.sergievPosad, .saintPetersburg]
        case .southAmerica: [.southAmerica]
        case .all: PreviewTrip.allCases
        }

        return trips.map {
            makeTrip(from: $0, with: options, referenceDay: referenceDay, createdAt: referenceDate)
        }
    }

    /// Создает пример поездки.
    /// - Parameters:
    ///   - previewTrip: Предопределенная поездка.
    ///   - includeLocations: Включать ли локации поездки.
    ///   - includeExpenses: Включать ли траты локаций и общие траты, в том числе без локаций.
    ///   - referenceDate: Общий момент генерации; календарный день определяется в текущем поясе.
    static func makeExampleTrip(
        _ previewTrip: PreviewTrip = .balkans,
        includeLocations: Bool = false,
        includeExpenses: Bool = false,
        referenceDate: Date = .now
    ) -> Trip {
        let options = PreviewOptions(includeLocations: includeLocations, includeExpenses: includeExpenses)
        return makeTrip(
            from: previewTrip,
            with: options,
            referenceDay: PlainDate(referenceDate, using: .current),
            createdAt: referenceDate
        )
    }

    /// Создает пример локации с родительской поездкой.
    /// - Parameters:
    ///   - previewLocation: Предопределенная локация.
    ///   - includeExpenses: Включать ли траты локации.
    ///   - referenceDate: Общий момент генерации; календарный день определяется в текущем поясе.
    static func makeExampleLocation(
        _ previewLocation: PreviewLocation = .belgrade,
        includeExpenses: Bool = false,
        referenceDate: Date = .now
    ) -> Location {
        let referenceDay = PlainDate(referenceDate, using: .current)
        let trip = makeTrip(
            from: previewLocation.tripData,
            with: PreviewOptions(includeLocations: false, includeExpenses: includeExpenses),
            referenceDay: referenceDay,
            createdAt: referenceDate
        )
        return makeLocation(
            from: previewLocation,
            to: trip,
            with: PreviewOptions(includeExpenses: includeExpenses),
            referenceDay: referenceDay,
            createdAt: referenceDate
        )
    }

    /// Создает пример сегодняшней траты с родительскими локацией и поездкой.
    /// - Parameters:
    ///   - previewLocation: Локация траты.
    ///   - referenceDate: Общий момент генерации; день траты определяется в текущем поясе.
    static func makeExampleExpense(
        of previewLocation: PreviewLocation = .belgrade,
        referenceDate: Date = .now
    ) -> Expense {
        let location = makeExampleLocation(previewLocation, referenceDate: referenceDate)
        var calendar = Calendar.utc
        guard let timeZone = TimeZone(identifier: previewLocation.timeZoneID) else {
            preconditionFailure("Invalid preview time zone: \(previewLocation.timeZoneID)")
        }
        calendar.timeZone = timeZone
        let sample = ExpensePreviewSample(
            date: CivilDateTime(referenceDate, using: calendar).storedDate,
            amount: 650,
            currency: previewLocation.currency,
            timeZoneID: previewLocation.timeZoneID,
            paymentMethod: .card,
            subcategory: .breakfast,
            comment: "Завтрак и кофе перед прогулкой",
            coordinate: previewLocation.centerPoint
        )
        let expense = makeExpense(from: sample, to: location, createdAt: referenceDate)
        location.expenses = [expense]
        return expense
    }

    /// Возвращает координаты центра примера локации.
    /// - Parameter previewLocation: Локация, для которой запрашивается центр.
    static func makeExampleCoordinate(_ previewLocation: PreviewLocation = .belgrade) -> Coordinate {
        previewLocation.centerPoint
    }
}

// MARK: - Конструкторы данных

private extension PreviewGenerator {
    static func makeTrip(
        from data: PreviewTrip,
        with options: PreviewOptions,
        referenceDay: PlainDate,
        createdAt: Date
    ) -> Trip {
        let trip = Trip(
            id: UUID(),
            name: data.name,
            startDate: data.startDate(relativeTo: referenceDay).storedDate,
            endDate: data.endDate(relativeTo: referenceDay).storedDate,
            homeCurrencyCode: Currency.defaultValue.code,
            locations: [],
            createdAt: createdAt,
            updatedAt: createdAt
        )

        if options.includeExpenses && options.includeGeneralExpenses {
            trip.generalExpenses = data.locationsData.flatMap { location in
                PreviewExpenseSamples.makeSamples(for: location, referenceDay: referenceDay)
                    .filter { $0.subcategory == .plane }
                    .map { makeExpense(from: $0, location: nil, trip: trip, exchangeAdjustment: location.exchangeAdjustment, createdAt: createdAt) }
            }
            trip.generalExpensesBudget = data.generalExpensesBudget
        }

        if options.includeLocations {
            trip.locations = data.locationsData.map {
                makeLocation(from: $0, to: trip, with: options, referenceDay: referenceDay, createdAt: createdAt)
            }
        }

        return trip
    }

    static func makeLocation(
        from data: PreviewLocation,
        to trip: Trip,
        with options: PreviewOptions,
        referenceDay: PlainDate,
        createdAt: Date
    ) -> Location {
        let location = Location(
            id: UUID(),
            name: data.name,
            startDate: data.startDate(relativeTo: referenceDay).storedDate,
            endDate: data.endDate(relativeTo: referenceDay).storedDate,
            locationCurrencyCode: data.currency.code,
            rateLocationToHome: data.rateLocationToHome,
            exchangeAdjustment: data.exchangeAdjustment,
            budget: data.budget,
            trip: trip,
            expenses: [],
            createdAt: createdAt,
            updatedAt: createdAt
        )

        if options.includeExpenses {
            let samples = PreviewExpenseSamples.makeSamples(for: data, referenceDay: referenceDay)
            location.expenses = samples.filter {
                !options.includeGeneralExpenses || $0.subcategory != .plane
            }.map {
                makeExpense(from: $0, to: location, createdAt: createdAt)
            }
            if options.includeGeneralExpenses {
                let generalAmount = samples.filter { $0.subcategory == .plane }.reduce(0.0) { result, sample in
                    result + homeAmount(for: sample, exchangeAdjustment: data.exchangeAdjustment)
                }
                location.budget = max(0, location.budget - generalAmount)
            }
        }

        return location
    }

    static func makeExpense(from sample: ExpensePreviewSample, to location: Location, createdAt: Date) -> Expense {
        guard let trip = location.trip else { preconditionFailure("Missing preview trip") }
        return makeExpense(from: sample, location: location, trip: trip, exchangeAdjustment: location.exchangeAdjustment, createdAt: createdAt)
    }

    static func homeAmount(for sample: ExpensePreviewSample, exchangeAdjustment: Double) -> Double {
        let expenseRate = sample.currency == .rub ? 1 : PreviewExchangeRates.toHome(for: sample.currency) * sample.rateVariation
        let calculation = ExpenseCalculationContext(
            homeAmount: 0, homeCurrency: .rub, expenseCurrency: sample.currency,
            rateExpenseToHome: expenseRate, rateExpenseToLocation: expenseRate,
            paymentMethod: sample.paymentMethod, exchangeAdjustment: exchangeAdjustment
        )
        return sample.amount * calculation.exchangeRate(from: .expense, to: .home)
    }

    static func makeExpense(
        from sample: ExpensePreviewSample,
        location: Location?,
        trip: Trip,
        exchangeAdjustment: Double,
        createdAt: Date
    ) -> Expense {
        guard let timeZone = TimeZone(identifier: sample.timeZoneID) else {
            preconditionFailure("Invalid preview time zone: \(sample.timeZoneID)")
        }
        let locationRate = location.map { $0.locationCurrency == .rub ? 1 : $0.rateLocationToHome * sample.rateVariation } ?? 1
        let expenseRate = sample.currency == .rub ? 1 : PreviewExchangeRates.toHome(for: sample.currency) * sample.rateVariation
        let rateExpenseToLocation = expenseRate / locationRate
        let homeAmount = homeAmount(for: sample, exchangeAdjustment: exchangeAdjustment)

        return Expense(
            id: UUID(),
            date: sample.date,
            actualDate: CivilDateTime(sample.date).actualDate(using: timeZone),
            timeZoneID: sample.timeZoneID,
            homeAmount: homeAmount,
            expenseCurrencyCode: sample.currency.code,
            rateExpenseToHome: expenseRate,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethodRaw: sample.paymentMethod.rawValue,
            exchangeAdjustment: exchangeAdjustment,
            categoryRaw: sample.subcategory.category.rawValue,
            subcategoryRaw: sample.subcategory.rawValue,
            location: location,
            trip: location == nil ? trip : nil,
            latitude: sample.coordinate?.latitude,
            longitude: sample.coordinate?.longitude,
            horizontalAccuracy: sample.coordinate?.horizontalAccuracy,
            comment: sample.comment,
            isExcludedFromDailySpending: sample.isExcludedFromDailySpending || [.hotel, .accommodationRental].contains(sample.subcategory),
            createdAt: createdAt,
            updatedAt: createdAt
        )
    }
}
