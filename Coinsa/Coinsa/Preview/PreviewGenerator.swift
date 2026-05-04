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
    var includeBudgets = true
    var includeExpenses = true
}

// MARK: - Генерартор превью-данных

/// Генератор тестовых данных для использования в превью SwiftUI.
enum PreviewGenerator {
    // MARK: - Свойства
    
    private static let now = Date().startOfDay
    
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
            startDate: data.startDate.startOfDay.utcNoon,
            endDate: data.endDate.endOfDay.utcNoon,
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
            startDate: data.startDate.startOfDay.utcNoon,
            endDate: data.endDate.endOfDay.utcNoon,
            timeZoneID: data.majorTimeZone.id,
            localCurrencyCode: data.currency.code,
            rateLocalToBase: data.rateLocalToBase,
            exchangeAdjustment: data.exchangeAdjustment,
            trip: trip,
            budgets: [],
            expenses: [],
            createdAt: now,
            updatedAt: now
        )
        
        if options.includeBudgets {
            includeBudgets(of: data, to: location)
        }
    
        if options.includeExpenses {
            includeExpenses(of: data, to: location)
        }
        
        return location
    }
    
    /// Создает трату с заданными параметрами.
    /// - Parameters:
    ///   - location: Локация расхода.
    ///   - date: Дата расхода.
    ///   - baseAmount: Сумма в основной валюте.
    ///   - rateLocalToBase: Курс местной валюты (опционально).
    ///   - paymentMethod: Способ оплаты. По умолчанию `.cash`.
    ///   - exchangeAdjustment: Поправка курса (опционально).
    ///   - category: Категория расхода.
    ///   - comment: Комментарий (опционально).
    /// - Returns: Сгенерированный расход.
    private static func makeExpense(
        to location: Location,
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double? = nil,
        paymentMethod: PaymentMethod = .cash,
        exchangeAdjustment: Double? = nil,
        category: ExpenseCategory,
        comment: String? = nil
    ) -> Expense {
        let now = Date()
        return Expense(
            id: UUID(),
            date: date,
            baseAmount: baseAmount,
            rateLocalToBase: rateLocalToBase ?? location.rateLocalToBase,
            paymentMethodRaw: paymentMethod.rawValue,
            exchangeAdjustment: exchangeAdjustment ?? location.exchangeAdjustment,
            categoryRaw: category.rawValue,
            location: location,
            comment: comment,
            createdAt: now,
            updatedAt: now
        )
    }
}

// MARK: - Генерация подчиненных объектов наборов данных

private extension PreviewGenerator {
    /// Добавляет бюджеты в локацию на основе предопределенных данных.
    /// - Parameters:
    ///   - previewLocation: Предопределенные данные локации.
    ///   - location: Локация для добавления бюджетов.
    private static func includeBudgets(of previewLocation: PreviewLocation, to location: Location) {
        var budgetsByCategory: [ExpenseCategory: Double] = [:]
        
        switch previewLocation {
        case .tokyo:
            budgetsByCategory = [
                .food: 22000,
                .transport: 7200,
                .activity: 12550,
                .shopping: 29500,
                .medicine: 2000,
                .other: 9490
            ]
        case .kyoto:
            budgetsByCategory = [
                .food: 18000,
                .activity: 5000,
                .shopping: 19000,
                .other: 20500
            ]
        case .osaka:
            budgetsByCategory = [
                .food: 14000,
                .transport: 6500,
                .other: 30000
            ]
        case .saintp:
            budgetsByCategory = [
                .food: 6000,
                .transport: 1500,
                .activity: 4000,
                .other: 2000
            ]
        case .seoul:
            budgetsByCategory = [
                .food: 26000,
                .transport: 6200,
                .activity: 18000,
                .shopping: 24000
            ]
        case .busan:
            budgetsByCategory = [
                .food: 14000,
                .transport: 3200,
                .other: 16000
            ]
        case .istanbul:
            budgetsByCategory = [
                .food: 21000,
                .transport: 3600,
                .activity: 8200,
                .shopping: 6800,
                .other: 4200
            ]
        }
        
        location.applyBudgets(budgetsByCategory)
    }
    
    /// Добавляет расходы в локацию на основе предопределенных данных.
    /// - Parameters:
    ///   - previewLocation: Предопределенные данные локации.
    ///   - location: Локация для добавления расходов.
    private static func includeExpenses(of previewLocation: PreviewLocation, to location: Location) {
        var expenses: [Expense] = []
        
        switch previewLocation {
        case .tokyo:
            expenses = makeTokyoExpenses(location)
        case .kyoto:
            expenses = makeKyotoExpenses(location)
        case .osaka:
            expenses = makeOsakaExpenses(location)
        case .saintp:
            expenses = makeSaintpExpenses(location)
        case .seoul:
            expenses = makeSeoulExpenses(location)
        default:
            expenses = []
        }
        
        location.expenses = expenses
    }
}

private extension PreviewGenerator {
    private static func makeTokyoExpenses(_ location: Location) -> [Expense] {
        let startDate = location.startDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 8, minutes: 45),
                baseAmount: 2300,
                category: .food,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13, minutes: 20),
                baseAmount: 2116.4,
                category: .other
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13, minutes: 58),
                baseAmount: 120,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 17, minutes: 11),
                baseAmount: 3200,
                category: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 23, minutes: 31),
                baseAmount: 1992,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 4),
                baseAmount: 140,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 12, minutes: 12),
                baseAmount: 2120,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 18, minutes: 31),
                baseAmount: 8902,
                paymentMethod: .card,
                exchangeAdjustment: 3.8,
                category: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 18, minutes: 31),
                baseAmount: 8902,
                category: .shopping,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 23),
                baseAmount: 1220,
                category: .medicine,
                comment: PreviewExpenseComment.pharmacy.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 8, minutes: 24),
                baseAmount: 240,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 12, minutes: 01),
                baseAmount: 3098.4,
                category: .food,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 15, minutes: 58),
                baseAmount: 3409.72,
                paymentMethod: .card,
                category: .activity,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 17),
                baseAmount: 312,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 20, minutes: 52),
                baseAmount: 12091.07,
                paymentMethod: .card,
                category: .shopping,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 11, minutes: 15),
                baseAmount: 887.01,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 12, minutes: 53),
                baseAmount: 2590,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 14, minutes: 11),
                baseAmount: 1450,
                category: .other,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 16, minutes: 40),
                baseAmount: 90,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 19, minutes: 28),
                baseAmount: 2500,
                category: .shopping,
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 23, minutes: 5),
                baseAmount: 1841.98,
                category: .food,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 10, minutes: 15),
                baseAmount: 1882,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 14, minutes: 19),
                baseAmount: 500,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 14, minutes: 59),
                baseAmount: 1003.6,
                category: .other
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 17, minutes: 30),
                baseAmount: 5902,
                paymentMethod: .card,
                exchangeAdjustment: 4.5,
                category: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 5, hours: 19, minutes: 30),
                baseAmount: 2600,
                category: .other,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 20, minutes: 50),
                baseAmount: 202,
                category: .transport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 4, hours: 23, minutes: 42),
                baseAmount: 3850,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food
            ),
        ]
    }
    
    private static func makeKyotoExpenses(_ location: Location) -> [Expense] {
        let startDate = location.startDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 8, minutes: 14),
                baseAmount: 6250,
                category: .transport,
                comment: PreviewExpenseComment.train.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 9),
                baseAmount: 1200,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                comment: PreviewExpenseComment.snacks.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 19),
                baseAmount: 3509.9,
                paymentMethod: .card,
                category: .transport,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 54),
                baseAmount: 2500.05,
                category: .food,
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 13, minutes: 14),
                baseAmount: 5209.6,
                category: .activity,
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 20),
                baseAmount: 120,
                category: .medicine,
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 57),
                baseAmount: 2691,
                category: .food,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 16, minutes: 50),
                baseAmount: 890,
                category: .activity,
                comment: PreviewExpenseComment.temple.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 19, minutes: 10),
                baseAmount: 212,
                category: .transport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 20, minutes: 19),
                baseAmount: 1620.18,
                category: .other,
                comment: PreviewExpenseComment.souvenirs.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 9, minutes: 36),
                baseAmount: 2906.7,
                category: .food,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 53),
                baseAmount: 1105,
                category: .transport,
                comment: PreviewExpenseComment.bus.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 14, minutes: 32),
                baseAmount: 2000.05,
                paymentMethod: .card,
                category: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 16, minutes: 50),
                baseAmount: 2012,
                category: .other
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 20, minutes: 15),
                baseAmount: 29020,
                paymentMethod: .card,
                category: .shopping
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22, minutes: 28),
                baseAmount: 3040.84,
                category: .food,
                
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 9),
                baseAmount: 706,
                category: .food,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 12),
                baseAmount: 706,
                category: .transport,
                comment: PreviewExpenseComment.train.rawValue
            )
        ]
    }
    
    private static func makeOsakaExpenses(_ location: Location) -> [Expense] {
        let startDate = location.startDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 11, minutes: 49),
                baseAmount: 2099,
                category: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 15, minutes: 20),
                baseAmount: 201,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 16),
                baseAmount: 2720,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 17, minutes: 39),
                baseAmount: 290,
                category: .other,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 15),
                baseAmount: 290,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 27),
                baseAmount: 1556,
                category: .food,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 1),
                baseAmount: 6991.44,
                paymentMethod: .card,
                category: .shopping
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 14, minutes: 32),
                baseAmount: 4010,
                paymentMethod: .card,
                category: .other
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 18, minutes: 49),
                baseAmount: 1900.04,
                category: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 20, minutes: 59),
                baseAmount: 1500,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 10, minutes: 15),
                baseAmount: 2068,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 13, minutes: 13),
                baseAmount: 2400,
                paymentMethod: .card,
                exchangeAdjustment: 2,
                category: .activity,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 14, minutes: 20),
                baseAmount: 309.06,
                category: .transport,
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 19),
                baseAmount: 5200,
                paymentMethod: .card,
                exchangeAdjustment: 2,
                category: .shopping,
                comment: PreviewExpenseComment.clothes.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22),
                baseAmount: 2095,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 5, minutes: 1),
                baseAmount: 5252.9,
                paymentMethod: .card,
                category: .transport,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 7, minutes: 26),
                baseAmount: 4520,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 8, minutes: 44),
                baseAmount: 6270,
                paymentMethod: .card,
                exchangeAdjustment: 5.5,
                category: .other
            )
        ]
    }

    private static func makeSaintpExpenses(_ location: Location) -> [Expense] {
        let startDate = location.startDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 10, minutes: 19),
                baseAmount: 2990,
                paymentMethod: .card,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 13),
                baseAmount: 950,
                paymentMethod: .card,
                category: .transport,
                comment: PreviewExpenseComment.taxi.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 17),
                baseAmount: 2400,
                paymentMethod: .card,
                category: .activity,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 33),
                baseAmount: 1800,
                paymentMethod: .card,
                category: .food
            )
        ]
    }
    
    private static func makeSeoulExpenses(_ location: Location) -> [Expense] {
        let startDate = location.startDate.startOfDay
        
        return [
            makeExpense(
                to: location,
                date: startDate.adding(hours: 8, minutes: 15),
                baseAmount: 3205.92,
                category: .food,
                comment: PreviewExpenseComment.breakfast.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 9, minutes: 14),
                baseAmount: 312,
                category: .transport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 14, minutes: 12),
                baseAmount: 2300,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 15, minutes: 53),
                baseAmount: 150,
                category: .other
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 16, minutes: 14),
                baseAmount: 924.13,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 19, minutes: 49),
                baseAmount: 9200.2,
                paymentMethod: .card,
                category: .shopping
            ),
            makeExpense(
                to: location,
                date: startDate.adding(hours: 21, minutes: 10),
                baseAmount: 2910,
                paymentMethod: .card,
                exchangeAdjustment: 0,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 9, minutes: 11),
                baseAmount: 2450,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 10, minutes: 15),
                baseAmount: 292.4,
                category: .transport,
                comment: PreviewExpenseComment.subway.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 13, minutes: 13),
                baseAmount: 1043,
                paymentMethod: .card,
                category: .activity,
                comment: PreviewExpenseComment.museum.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 15, minutes: 16),
                baseAmount: 1687,
                category: .food,
                comment: PreviewExpenseComment.lunch.rawValue
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 16, minutes: 37),
                baseAmount: 300,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 1, hours: 19, minutes: 50),
                baseAmount: 2540.14,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 11),
                baseAmount: 2051.51,
                category: .food,
                comment: PreviewExpenseComment.streetFood.rawValue
            ),
            makeExpense(to: location,
                date: startDate.adding(days: 2, hours: 12, minutes: 7),
                baseAmount: 199.3,
                paymentMethod: .card,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 17, minutes: 59),
                baseAmount: 14200,
                paymentMethod: .card,
                category: .activity
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 19, minutes: 40),
                baseAmount: 1250,
                paymentMethod: .card,
                exchangeAdjustment: 6,
                category: .other
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 22, minutes: 1),
                baseAmount: 1940.2,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 2, hours: 23, minutes: 44),
                baseAmount: 1001,
                paymentMethod: .card,
                exchangeAdjustment: 1,
                category: .medicine
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 10, minutes: 14),
                baseAmount: 2046,
                category: .food
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 11, minutes: 35),
                baseAmount: 199,
                category: .transport
            ),
            makeExpense(
                to: location,
                date: startDate.adding(days: 3, hours: 15, minutes: 42),
                baseAmount: 765,
                paymentMethod: .card,
                category: .other,
                comment: PreviewExpenseComment.miscellaneous.rawValue
            )
        ]
    }
}
