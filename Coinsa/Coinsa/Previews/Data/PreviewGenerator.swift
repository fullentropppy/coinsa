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
    case japan
    case russia
    case southKorea
    case turkey
    case all
}

/// Настройки включения связанных данных при генерации.
struct PreviewOptions {
    var includeTrips = true
    var includeLocations = true
    var includeExpenses = true
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
        case .japan: [.japan]
        case .russia: [.russia]
        case .southKorea: [.southKorea]
        case .turkey: [.turkey]
        case .all: [.japan, .russia, .southKorea, .turkey]
        }

        return trips.map {
            makeTrip(from: $0, with: options, referenceDay: referenceDay, createdAt: referenceDate)
        }
    }

    /// Создает пример поездки.
    /// - Parameters:
    ///   - previewTrip: Предопределенная поездка.
    ///   - includeLocations: Включать ли локации поездки.
    ///   - includeExpenses: Включать ли траты; игнорируется без локаций.
    ///   - referenceDate: Общий момент генерации; календарный день определяется в текущем поясе.
    static func makeExampleTrip(
        _ previewTrip: PreviewTrip = .southKorea,
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
        _ previewLocation: PreviewLocation = .seoul,
        includeExpenses: Bool = false,
        referenceDate: Date = .now
    ) -> Location {
        let referenceDay = PlainDate(referenceDate, using: .current)
        let trip = makeTrip(
            from: previewLocation.tripData,
            with: PreviewOptions(includeLocations: false, includeExpenses: false),
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
        of previewLocation: PreviewLocation = .seoul,
        referenceDate: Date = .now
    ) -> Expense {
        let location = makeExampleLocation(previewLocation, referenceDate: referenceDate)
        let center = previewLocation.centerPoint
        let sample = ExpensePreviewSample(
            date: PlainDate(referenceDate, using: .current).storedDate.adding(hours: 12, minutes: 30, using: .utc),
            homeAmount: 2600,
            category: .food,
            subcategory: .breakfast,
            comment: PreviewExpenseComment.breakfast.rawValue,
            latitude: center.latitude,
            longitude: center.longitude,
            horizontalAccuracy: center.horizontalAccuracy
        )
        let expense = makeExpense(from: sample, to: location, timeZoneID: previewLocation.timeZoneID, createdAt: referenceDate)
        location.expenses = [expense]
        return expense
    }

    /// Возвращает координаты центра примера локации.
    /// - Parameter previewLocation: Локация, для которой запрашивается центр.
    static func makeExampleCoordinate(_ previewLocation: PreviewLocation = .seoul) -> Coordinate {
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
            location.expenses = expenseSamples(for: data, startDate: location.startPlainDate.startOfDay).map {
                makeExpense(from: $0, to: location, timeZoneID: data.timeZoneID, createdAt: createdAt)
            }
        }

        return location
    }

    static func makeExpense(from sample: ExpensePreviewSample, to location: Location, timeZoneID: String, createdAt: Date) -> Expense {
        guard let timeZone = TimeZone(identifier: timeZoneID) else {
            fatalError("Invalid preview time zone: \(timeZoneID)")
        }

        return Expense(
            id: UUID(),
            date: sample.date,
            actualDate: CivilDateTime(sample.date).actualDate(using: timeZone),
            timeZoneID: timeZoneID,
            homeAmount: sample.homeAmount,
            expenseCurrencyCode: location.locationCurrency.code,
            rateExpenseToHome: location.rateLocationToHome,
            rateExpenseToLocation: 1,
            paymentMethodRaw: sample.paymentMethod.rawValue,
            exchangeAdjustment: sample.exchangeAdjustment ?? location.exchangeAdjustment,
            categoryRaw: sample.category.rawValue,
            subcategoryRaw: sample.subcategory.rawValue,
            location: location,
            latitude: sample.latitude,
            longitude: sample.longitude,
            horizontalAccuracy: sample.horizontalAccuracy,
            comment: sample.comment,
            createdAt: createdAt,
            updatedAt: createdAt
        )
    }

    static func expenseSamples(for location: PreviewLocation, startDate: Date) -> [ExpensePreviewSample] {
        switch location {
        case .tokyo: TokyoExpenseSamples.makeSamples(startDate: startDate)
        case .kyoto: KyotoExpenseSamples.makeSamples(startDate: startDate)
        case .osaka: OsakaExpenseSamples.makeSamples(startDate: startDate)
        case .saintp: SaintPetersburgExpenseSamples.makeSamples(startDate: startDate)
        case .seoul: SeoulExpenseSamples.makeSamples(startDate: startDate)
        case .busan, .istanbul: []
        }
    }
}
