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
        comment: String? = nil
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
            latitude: nil,
            longitude: nil,
            horizontalAccuracy: nil,
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
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2116.4,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13, minutes: 58),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 120,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 17, minutes: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3200,
                category: .leisure,
                subcategory: .entertainment
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 23, minutes: 31),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1992,
                category: .food,
                subcategory: .dinner
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
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 12, minutes: 12),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2120,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .food,
                subcategory: .lunch
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 18, minutes: 31),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 8902,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .leisure,
                subcategory: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 20, minutes: 40),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 8150,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 23),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1220,
                category: .medicine,
                subcategory: .medication,
                comment: PreviewExpenseComment.pharmacy.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 8, minutes: 24),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 240,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 12, minutes: 01),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3098.4,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 15, minutes: 58),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3409.72,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 17),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 312,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 20, minutes: 52),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 12091.07,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .clothing,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 11, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 887.01,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 12, minutes: 53),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2590,
                category: .food,
                subcategory: .lunch
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 14, minutes: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1450,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 16, minutes: 40),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 90,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 19, minutes: 28),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2500,
                category: .shopping,
                subcategory: .cosmetics
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 23, minutes: 5),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1841.98,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 10, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1882,
                category: .food,
                subcategory: .breakfast
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 14, minutes: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 500,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                subcategory: .taxi
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 14, minutes: 59),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1003.6,
                category: .miscellaneous,
                subcategory: .digitalService
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 17, minutes: 30),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 5902,
                paymentMethod: .card,
                exchangeAdjustment: 4.5,
                category: .leisure,
                subcategory: .tour
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 5, hours: 19, minutes: 30),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2600,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 20, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 202,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 23, minutes: 42),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3850,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .dinner
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
                comment: PreviewExpenseComment.train.rawValue
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
                comment: PreviewExpenseComment.snacks.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3509.9,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .entertainment,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 54),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2500.05,
                category: .food,
                subcategory: .lunch
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 13, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 5209.6,
                category: .leisure,
                subcategory: .tour
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 120,
                category: .medicine,
                subcategory: .medication
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 57),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2691,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 16, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 890,
                category: .leisure,
                subcategory: .park,
                comment: PreviewExpenseComment.temple.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 19, minutes: 10),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 212,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 20, minutes: 19),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1620.18,
                category: .shopping,
                subcategory: .souvenirs,
                comment: PreviewExpenseComment.souvenirs.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 9, minutes: 36),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2906.7,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 53),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1105,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 14, minutes: 32),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2000.05,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 16, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2012,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 20, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 29020,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .electronics
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22, minutes: 28),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 3040.84,
                category: .food,
                subcategory: .dinner
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 9),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 706,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 12),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 706,
                category: .transport,
                subcategory: .train,
                comment: PreviewExpenseComment.train.rawValue
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
                subcategory: .landmark
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 15, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 201,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 16),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2720,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .lunch
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 17, minutes: 39),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 290,
                category: .miscellaneous,
                subcategory: .donation,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 290,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .snack
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 27),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1556,
                category: .food,
                subcategory: .breakfast,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 32),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 4010,
                paymentMethod: .card,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 18, minutes: 49),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1900.04,
                category: .leisure,
                subcategory: .landmark
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
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2068,
                category: .food,
                subcategory: .breakfast
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
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 14, minutes: 20),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 309.06,
                category: .transport,
                subcategory: .publicTransport
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
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2095,
                category: .food,
                subcategory: .dinner
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 5, minutes: 1),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 5252.9,
                paymentMethod: .card,
                category: .transport,
                subcategory: .taxi,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 7, minutes: 26),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 4520,
                category: .food,
                subcategory: .breakfast
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 8, minutes: 44),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 6270,
                paymentMethod: .card,
                exchangeAdjustment: 5.5,
                category: .miscellaneous,
                subcategory: .otherMiscellaneous
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
                subcategory: .breakfast
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 950,
                paymentMethod: .card,
                category: .transport,
                subcategory: .taxi,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 17),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2400,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 33),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1800,
                paymentMethod: .card,
                category: .food,
                subcategory: .dinner
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
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 9, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 312,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue
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
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 15, minutes: 53),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 150,
                category: .miscellaneous,
                subcategory: .bankFees
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 924.13,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 19, minutes: 49),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 9200.2,
                paymentMethod: .card,
                category: .shopping,
                subcategory: .jewelry
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 10),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2910,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                subcategory: .dinner
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 9, minutes: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2450,
                category: .food,
                subcategory: .breakfast
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 15),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 292.4,
                category: .transport,
                subcategory: .publicTransport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 13, minutes: 13),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1043,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .landmark,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 15, minutes: 16),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1687,
                category: .food,
                subcategory: .lunch,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 16, minutes: 37),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 300,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 19, minutes: 50),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2540.14,
                category: .food,
                subcategory: .dinner
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 11),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2051.51,
                category: .food,
                subcategory: .snack,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            makeExpense(to: location,
                date: startDate.adding(days: 2, hours: 12, minutes: 7),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 199.3,
                paymentMethod: .card,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 17, minutes: 59),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 14200,
                paymentMethod: .card,
                category: .leisure,
                subcategory: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 19, minutes: 40),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1250,
                paymentMethod: .card,
                exchangeAdjustment: 6,
                category: .miscellaneous,
                subcategory: .laundry
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22, minutes: 1),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1940.2,
                category: .food,
                subcategory: .dinner
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 23, minutes: 44),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 1001,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine,
                subcategory: .medication
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 10, minutes: 14),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 2046,
                category: .food,
                subcategory: .breakfast
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 11, minutes: 35),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 199,
                category: .transport,
                subcategory: .publicTransport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 15, minutes: 42),
                timeZoneId: previewLocation.timeZoneId,
                baseAmount: 765,
                paymentMethod: .card,
                category: .miscellaneous,
                subcategory: .bankFees,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            )
        ]
    }
}
