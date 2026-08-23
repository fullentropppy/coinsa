//
//  PreviewGenerator.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import Foundation

// MARK: - Публичные типы

/// Сценарии генерации данных для превью.
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

// MARK: - Генерартор превью-данных

/// Генератор тестовых данных для использования в превью SwiftUI.
enum PreviewGenerator {
    // MARK: - Свойства
    
    private static let now = PlainDate.today.storedDate
    
    // MARK: - Публичные методы
    
    /// Создает массив поездок согласно сценарию и настройкам.
    /// - Parameters:
    ///   - scenario: Сценарий генерации.
    ///   - options: Настройки включения подчиненных объектов.
    /// - Returns: Массив сгенерированных поездок.
    static func makeTrips(for scenario: PreviewScenario, options: PreviewOptions) -> [Trip] {
        var trips: [Trip] = []
        
        if !options.includeTrips {
            return trips
        }
        if scenario == .all || scenario == .japan {
            trips.append(makeTrip(from: PreviewTrip.japan, with: options))
        }
        if scenario == .all || scenario == .russia {
            trips.append(makeTrip(from: PreviewTrip.russia, with: options))
        }
        if scenario == .all || scenario == .southKorea {
            trips.append(makeTrip(from: PreviewTrip.southKorea, with: options))
        }
        if scenario == .all || scenario == .turkey {
            trips.append(makeTrip(from: PreviewTrip.turkey, with: options))
        }
        
        return trips
    }
}

// MARK: - Конструкторы данных

private extension PreviewGenerator {
    /// Создает поездку на основе предопределенных данных.
    /// - Parameters:
    ///   - data: Предопределенные данные поездки.
    ///   - options: Настройки включения подчиненных объектов.
    /// - Returns: Сгенерированная поездка.
    private static func makeTrip(from data: PreviewTrip, with options: PreviewOptions) -> Trip {
        let now = Date()
        let trip = Trip(
            id: UUID(),
            name: data.name,
            startDate: PlainDate(data.startDate).storedDate,
            endDate: PlainDate(data.endDate).storedDate,
            baseCurrencyCode: Currency.defaultValue.code,
            locations: [],
            createdAt: now,
            updatedAt: now
        )
        
        if options.includeLocations {
            var locations: [Location] = []
            for locationData in data.locationsData {
                let location = makeLocation(from: locationData, to: trip, with: options)
                locations.append(location)
            }
            trip.locations = locations
        }
        
        return trip
    }
    
    /// Создает локацию на основе предопределенных данных.
    /// - Parameters:
    ///   - data: Предопределенные данные локации.
    ///   - trip: Родительская поездка.
    ///   - options: Настройки включения подчиненных объектов.
    /// - Returns: Сгенерированная локация.
    private static func makeLocation(from data: PreviewLocation, to trip: Trip, with options: PreviewOptions) -> Location {
        let now = Date()
        let location =  Location(
            id: UUID(),
            name: data.name,
            startDate: PlainDate(data.startDate).storedDate,
            endDate: PlainDate(data.endDate).storedDate,
            locationCurrencyCode: data.currency.code,
            rateLocationToBase: data.rateLocationToBase,
            exchangeAdjustment: data.exchangeAdjustment,
            budget: data.budget,
            trip: trip,
            expenses: [],
            createdAt: now,
            updatedAt: now
        )
        
        if options.includeExpenses {
            includeExpenses(of: data, to: location)
        }
        
        return location
    }
    
    /// Создает трату с заданными параметрами.
    /// - Parameters:
    ///   - location: Локация расхода.
    ///   - date: Дата расхода.
    ///   - timeZoneId: Идентификатор часового пояса расхода.
    ///   - baseAmount: Сумма в основной валюте.
    ///   - expenseCurrencyCode: Код валюты траты (опицонально).
    ///   - rateExpenseToBase: Курс валюты траты к основной (опционально).
    ///   - rateExpenseToLocation: Курс валюты траты к валюте локации (опционально).
    ///   - paymentMethod: Способ оплаты. По умолчанию `.cash`.
    ///   - exchangeAdjustment: Поправка курса (опционально).
    ///   - category: Категория расхода.
    ///   - subcategory: Подкатегория расхода.
    ///   - comment: Комментарий (опционально).
    /// - Returns: Сгенерированный расход.
    private static func makeExpense(
        to location: Location,
        date: Date,
        timeZoneId: String,
        baseAmount: Double,
        expenseCurrencyCode: Currency? = nil,
        rateExpenseToBase: Double? = nil,
        rateExpenseToLocation: Double? = nil,
        paymentMethod: PaymentMethod = .cash,
        exchangeAdjustment: Double? = nil,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        comment: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        horizontalAccuracy: Double? = nil
    ) -> Expense {
        let now = Date()
        return Expense(
            id: UUID(),
            date: date,
            actualDate: CivilDateTime(date, using: .utc).actualDate(),
            timeZoneId: timeZoneId,
            baseAmount: baseAmount,
            expenseCurrencyCode: expenseCurrencyCode?.code ?? location.locationCurrency.code,
            rateExpenseToBase: rateExpenseToBase ?? location.rateLocationToBase,
            rateExpenseToLocation: rateExpenseToLocation ?? 1,
            paymentMethodRaw: paymentMethod.rawValue,
            exchangeAdjustment: exchangeAdjustment ?? location.exchangeAdjustment,
            categoryRaw: category.rawValue,
            subcategoryRaw: subcategory.rawValue,
            location: location,
            latitude: latitude,
            longitude: longitude,
            horizontalAccuracy: horizontalAccuracy,
            comment: comment,
            createdAt: now,
            updatedAt: now
        )
    }
}

// MARK: - Генерация подчиненных объектов наборов данных

private extension PreviewGenerator {
    /// Добавляет расходы в локацию на основе предопределенных данных.
    /// - Parameters:
    ///   - previewLocation: Предопределенные данные локации.
    ///   - location: Локация для добавления расходов.
    private static func includeExpenses(of previewLocation: PreviewLocation, to location: Location) {
        var expenses: [Expense] = []
        
        switch previewLocation {
        case .tokyo:
            expenses = makeTokyoExpenses(location, with: previewLocation)
        case .kyoto:
            expenses = makeKyotoExpenses(location, with: previewLocation)
        case .osaka:
            expenses = makeOsakaExpenses(location, with: previewLocation)
        case .saintp:
            expenses = makeSaintpExpenses(location, with: previewLocation)
        case .seoul:
            expenses = makeSeoulExpenses(location, with: previewLocation)
        default:
            expenses = []
        }
        
        location.expenses = expenses
    }
}

private extension PreviewGenerator {
    private static func makeTokyoExpenses(_ location: Location, with previewLocation: PreviewLocation) -> [Expense] {
        let startDate = location.startPlainDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 8, minutes: 45),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2300,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.6595,
                longitude: 139.7004,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2116.4,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 35.6812,
                longitude: 139.7671,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13, minutes: 58),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 120,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6814,
                longitude: 139.7663,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 17, minutes: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3200,
                category: .leisure,
                subcategory: .entertainment,
                latitude: 35.6594,
                longitude: 139.7005,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 23, minutes: 31),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1992,
                category: .food,
                subcategory: .dinner,
                latitude: 35.6601,
                longitude: 139.6998,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 4),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 140,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 35.6815,
                longitude: 139.7665,
                horizontalAccuracy: 8.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 12, minutes: 12),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2120,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .food,
                subcategory: .lunch,
                latitude: 35.6598,
                longitude: 139.7002,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 18, minutes: 31),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 8902,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .leisure,
                subcategory: .activity,
                latitude: 35.6603,
                longitude: 139.6995,
                horizontalAccuracy: 25.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 20, minutes: 40),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 8150,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue,
                latitude: 35.6593,
                longitude: 139.7006,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 23),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1220,
                category: .medicine,
                subcategory: .medication,
                comment: PreviewExpenseComment.pharmacy.rawValue,
                latitude: 35.6605,
                longitude: 139.6992,
                horizontalAccuracy: 22.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 8, minutes: 24),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 240,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6813,
                longitude: 139.7664,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 12, minutes: 01),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3098.4,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.6597,
                longitude: 139.7003,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 15, minutes: 58),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3409.72,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 35.7147,
                longitude: 139.7967,
                horizontalAccuracy: 30.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 17),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 312,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6816,
                longitude: 139.7662,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 20, minutes: 52),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 12091.07,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue,
                latitude: 35.6590,
                longitude: 139.7008,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 11, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 887.01,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication,
                latitude: 35.6602,
                longitude: 139.6994,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 12, minutes: 53),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2590,
                category: .food,
                subcategory: .lunch,
                latitude: 35.6599,
                longitude: 139.7001,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 14, minutes: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1450,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 35.6604,
                longitude: 139.6996,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 16, minutes: 40),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 90,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 35.6812,
                longitude: 139.7666,
                horizontalAccuracy: 8.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 19, minutes: 28),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2500,
                category: .shopping,
                subcategory: .cosmetics,
                latitude: 35.6592,
                longitude: 139.7007,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 23, minutes: 5),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1841.98,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue,
                latitude: 35.6600,
                longitude: 139.7000,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 10, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1882,
                category: .food,
                subcategory: .breakfast,
                latitude: 35.6596,
                longitude: 139.7004,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 14, minutes: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 500,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .taxi,
                latitude: 35.6810,
                longitude: 139.7670,
                horizontalAccuracy: 25.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 14, minutes: 59),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1003.6,
                category: .miscellaneous,
                subcategory: .digitalService,
                latitude: 35.6606,
                longitude: 139.6991,
                horizontalAccuracy: 22.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 17, minutes: 30),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 5902,
                paymentMethod: .card,
                exchangeAdjustment: 4.5,
                category: .leisure,
                subcategory: .tour,
                latitude: 35.7149,
                longitude: 139.7969,
                horizontalAccuracy: 35.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 5, hours: 19, minutes: 30),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2600,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 35.6601,
                longitude: 139.6999,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 20, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 202,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 35.6817,
                longitude: 139.7661,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 23, minutes: 42),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3850,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .dinner,
                latitude: 35.6594,
                longitude: 139.7006,
                horizontalAccuracy: 14.0
            ),
        ]
    }
    
    private static func makeKyotoExpenses(_ location: Location, with previewLocation: PreviewLocation) -> [Expense] {
        let startDate = location.startPlainDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 8, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 6250,
                category: .transport,
                subcategory: .train,
                comment: PreviewExpenseComment.train.rawValue,
                latitude: 34.9853,
                longitude: 135.7593,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 9),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1200,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.snacks.rawValue,
                latitude: 35.0116,
                longitude: 135.7681,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3509.9,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .entertainment,
                comment: PreviewExpenseComment.taxi.rawValue,
                latitude: 35.0394,
                longitude: 135.7287,
                horizontalAccuracy: 25.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 54),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2500.05,
                category: .food,
                subcategory: .lunch,
                latitude: 35.0114,
                longitude: 135.7684,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 13, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 5209.6,
                category: .leisure,
                subcategory: .tour,
                latitude: 34.9948,
                longitude: 135.7585,
                horizontalAccuracy: 30.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 120,
                category: .medicine,
                subcategory: .medication,
                latitude: 35.0118,
                longitude: 135.7678,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 57),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2691,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue,
                latitude: 35.0115,
                longitude: 135.7683,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 16, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 890,
                category: .leisure,
                subcategory: .park,
                comment: PreviewExpenseComment.temple.rawValue,
                latitude: 34.9977,
                longitude: 135.7852,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 19, minutes: 10),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 212,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 35.0111,
                longitude: 135.7686,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 20, minutes: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1620.18,
                category: .shopping,
                subcategory: .souvenirs,
                comment: PreviewExpenseComment.souvenirs.rawValue,
                latitude: 35.0117,
                longitude: 135.7680,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 9, minutes: 36),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2906.7,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.0113,
                longitude: 135.7685,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 53),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1105,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.bus.rawValue,
                latitude: 34.9856,
                longitude: 135.7590,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 14, minutes: 32),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2000.05,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                latitude: 34.9945,
                longitude: 135.7588,
                horizontalAccuracy: 22.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 16, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2012,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 35.0119,
                longitude: 135.7677,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 20, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 29020,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .electronics,
                latitude: 35.0110,
                longitude: 135.7687,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22, minutes: 28),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3040.84,
                category: .food,
                subcategory: .dinner,
                latitude: 35.0116,
                longitude: 135.7682,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 9),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 706,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 35.0114,
                longitude: 135.7684,
                horizontalAccuracy: 13.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 12),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 706,
                category: .transport,
                subcategory: .train,
                comment: PreviewExpenseComment.train.rawValue,
                latitude: 34.9855,
                longitude: 135.7591,
                horizontalAccuracy: 20.0
            )
        ]
    }
    
    private static func makeOsakaExpenses(_ location: Location, with previewLocation: PreviewLocation) -> [Expense] {
        let startDate = location.startPlainDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 11, minutes: 49),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2099,
                category: .leisure,
                subcategory: .landmark,
                latitude: 34.6849,
                longitude: 135.5023,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 15, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 201,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 34.6855,
                longitude: 135.5018,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 16),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2720,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .lunch,
                latitude: 34.6682,
                longitude: 135.5023,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 17, minutes: 39),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 290,
                category: .miscellaneous,
                subcategory: .donation,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 34.6846,
                longitude: 135.5026,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 290,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .snack,
                latitude: 34.6685,
                longitude: 135.5020,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 27),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1556,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 34.6688,
                longitude: 135.5028,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 32),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 4010,
                paymentMethod: .card,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 34.6680,
                longitude: 135.5025,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 18, minutes: 49),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1900.04,
                category: .leisure,
                subcategory: .landmark,
                latitude: 34.6842,
                longitude: 135.5030,
                horizontalAccuracy: 22.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 20, minutes: 59),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1500,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue,
                latitude: 34.6683,
                longitude: 135.5026,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2068,
                category: .food,
                subcategory: .breakfast,
                latitude: 34.6687,
                longitude: 135.5022,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 13, minutes: 13),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2400,
                paymentMethod: .card,
                exchangeAdjustment: 2,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 34.6840,
                longitude: 135.5032,
                horizontalAccuracy: 25.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 14, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 309.06,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 34.6853,
                longitude: 135.5020,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 5200,
                paymentMethod: .card,
                exchangeAdjustment: 2,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue,
                latitude: 34.6681,
                longitude: 135.5029,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2095,
                category: .food,
                subcategory: .dinner,
                latitude: 34.6684,
                longitude: 135.5024,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 5, minutes: 1),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 5252.9,
                paymentMethod: .card,
                category: .transport,
                subcategory: .taxi,
                comment: PreviewExpenseComment.taxi.rawValue,
                latitude: 34.6850,
                longitude: 135.5015,
                horizontalAccuracy: 30.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 7, minutes: 26),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 4520,
                category: .food,
                subcategory: .breakfast,
                latitude: 34.6686,
                longitude: 135.5021,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 8, minutes: 44),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 6270,
                paymentMethod: .card,
                exchangeAdjustment: 5.5,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                latitude: 34.6844,
                longitude: 135.5028,
                horizontalAccuracy: 22.0
            )
        ]
    }
    
    private static func makeSaintpExpenses(_ location: Location, with previewLocation: PreviewLocation) -> [Expense] {
        let startDate = location.startPlainDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2990,
                paymentMethod: .card,
                category: .food,
                subcategory: .breakfast,
                latitude: 59.9386,
                longitude: 30.3141,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 950,
                paymentMethod: .card,
                category: .transport,
                subcategory: .taxi,
                comment: PreviewExpenseComment.taxi.rawValue,
                latitude: 59.9398,
                longitude: 30.3146,
                horizontalAccuracy: 25.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 17),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2400,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 59.9398,
                longitude: 30.3159,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 33),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1800,
                paymentMethod: .card,
                category: .food,
                subcategory: .dinner,
                latitude: 59.9389,
                longitude: 30.3138,
                horizontalAccuracy: 14.0
            )
        ]
    }
    
    private static func makeSeoulExpenses(_ location: Location, with previewLocation: PreviewLocation) -> [Expense] {
        let startDate = location.startPlainDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 8, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3205.92,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue,
                latitude: 37.5665,
                longitude: 126.9780,
                horizontalAccuracy: 15.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 9, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 312,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 37.5700,
                longitude: 126.9824,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 14, minutes: 12),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2300,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue,
                latitude: 37.5668,
                longitude: 126.9783,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 15, minutes: 53),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 150,
                category: .miscellaneous,
                subcategory: .bankFees,
                latitude: 37.5660,
                longitude: 126.9775,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 924.13,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication,
                latitude: 37.5672,
                longitude: 126.9788,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 19, minutes: 49),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 9200.2,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .jewelry,
                latitude: 37.5663,
                longitude: 126.9778,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 10),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2910,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .dinner,
                latitude: 37.5666,
                longitude: 126.9782,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 9, minutes: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2450,
                category: .food,
                subcategory: .breakfast,
                latitude: 37.5664,
                longitude: 126.9785,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 292.4,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue,
                latitude: 37.5698,
                longitude: 126.9822,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 13, minutes: 13),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1043,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue,
                latitude: 37.5795,
                longitude: 126.9770,
                horizontalAccuracy: 25.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 15, minutes: 16),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1687,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue,
                latitude: 37.5667,
                longitude: 126.9781,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 16, minutes: 37),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 300,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 37.5702,
                longitude: 126.9826,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 19, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2540.14,
                category: .food,
                subcategory: .dinner,
                latitude: 37.5669,
                longitude: 126.9779,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2051.51,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue,
                latitude: 37.5662,
                longitude: 126.9786,
                horizontalAccuracy: 12.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 12, minutes: 7),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 199.3,
                paymentMethod: .card,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 37.5701,
                longitude: 126.9825,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 14, minutes: 41),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 42900,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .electronics,
                latitude: 37.5658,
                longitude: 126.9772,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 17, minutes: 59),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 14200,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .activity,
                latitude: 37.5660,
                longitude: 126.9775,
                horizontalAccuracy: 22.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 19, minutes: 40),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1250,
                paymentMethod: .card,
                exchangeAdjustment: 6,
                category: .miscellaneous,
                subcategory: .laundry,
                latitude: 37.5670,
                longitude: 126.9787,
                horizontalAccuracy: 20.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22, minutes: 1),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1940.2,
                category: .food,
                subcategory: .dinner,
                latitude: 37.5665,
                longitude: 126.9784,
                horizontalAccuracy: 16.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 23, minutes: 44),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1001,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication,
                latitude: 37.5673,
                longitude: 126.9789,
                horizontalAccuracy: 18.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 10, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2046,
                category: .food,
                subcategory: .breakfast,
                latitude: 37.5663,
                longitude: 126.9783,
                horizontalAccuracy: 14.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 11, minutes: 35),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 199,
                category: .transport,
                subcategory: .publicTransport,
                latitude: 37.5703,
                longitude: 126.9827,
                horizontalAccuracy: 10.0
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 15, minutes: 42),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 765,
                paymentMethod: .card,
                category: .miscellaneous,
                subcategory: .bankFees,
                comment: PreviewExpenseComment.miscellaneous.rawValue,
                latitude: 37.5664,
                longitude: 126.9776,
                horizontalAccuracy: 20.0
            )
        ]
    }
}
