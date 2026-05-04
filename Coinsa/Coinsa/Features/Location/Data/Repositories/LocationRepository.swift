//
//  LocationRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation
import SwiftData

/// Репозиторий для выполнения операций CRUD над локациями.
@MainActor
struct LocationRepository {
    // MARK: - Свойства
    
    let context: ModelContext
    
    // MARK: - Операции с хранилищем
    
    /// Создает новую локацию.
    /// - Parameters:
    ///   - name: Название локации.
    ///   - startDate: Дата начала пребывания.
    ///   - endDate: Дата окончания пребывания.
    ///   - majorTimeZone: Часовой пояс.
    ///   - localCurrency: Локальная валюта.
    ///   - rateLocalToBase: Курс к основной валюте.
    ///   - exchangeAdjustment: Процентная корректировка курса.
    ///   - trip: Родительская поездка.
    ///   - budgetsByCategory: Бюджеты по категориям.
    func add(
        name: String,
        startDate: Date,
        endDate: Date,
        majorTimeZone: MajorTimeZone,
        localCurrency: Currency,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
        trip: Trip,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        let now = Date()
        
        let location = Location(
            id: UUID(),
            name: name.trimmed,
            startDate: normalizedStartDate(startDate),
            endDate: normalizedEndDate(endDate),
            timeZoneID: majorTimeZone.id,
            localCurrencyCode: localCurrency.code,
            rateLocalToBase: normalizedRateLocalToBase(rateLocalToBase),
            exchangeAdjustment: normalizedRateLocalToBase(exchangeAdjustment),
            trip: trip,
            budgets: [],
            expenses: [],
            createdAt: now,
            updatedAt: now
        )
        location.applyBudgets(budgetsByCategory)
        
        context.insert(location)
        try? context.save()
    }
    
    /// Обновляет существующую локацию.
    /// - Parameters:
    ///   - location: Локация для обновления.
    ///   - name: Новое название.
    ///   - startDate: Новая дата начала.
    ///   - endDate: Новая дата окончания.
    ///   - majorTimeZone: Новый часовой пояс.
    ///   - localCurrency: Новая локальная валюта.
    ///   - rateLocalToBase: Новый курс.
    ///   - exchangeAdjustment: Новая корректировка.
    ///   - budgetsByCategory: Новые бюджеты по категориям.
    func update(
        _ location: Location,
        name: String,
        startDate: Date,
        endDate: Date,
        majorTimeZone: MajorTimeZone,
        localCurrency: Currency,
        rateLocalToBase: Double,
        exchangeAdjustment: Double,
        budgetsByCategory: [ExpenseCategory: Double]
    ) {
        location.name = name.trimmed
        location.startDate = normalizedStartDate(startDate)
        location.endDate = normalizedEndDate(endDate)
        location.timeZoneID = majorTimeZone.id
        location.localCurrencyCode = localCurrency.code
        location.rateLocalToBase = normalizedRateLocalToBase(rateLocalToBase)
        location.exchangeAdjustment = normalizedRateLocalToBase(exchangeAdjustment)
        location.updatedAt = Date()
        location.applyBudgets(budgetsByCategory)
        
        try? context.save()
    }
    
    /// Удаляет локацию.
    /// - Parameter location: Локация для удаления.
    func delete(_ location: Location) {
        context.delete(location)
        try? context.save()
    }
    
    // MARK: - Номализация
    
    /// Очищает название от лишних пробелов.
    private func normalizedName(_ name: String) -> String {
        name.trimmed
    }
    
    /// Нормализует дату начала к полудню UTC.
    private func normalizedStartDate(_ startDate: Date) -> Date {
        startDate.utcNoon
    }
    
    /// Нормализует дату окончания к полудню UTC.
    private func normalizedEndDate(_ endDate: Date) -> Date {
        endDate.utcNoon
    }
    
    /// Приводит сумму к неотрицательному значению.
    private func normalizedAmount(_ amount: Double) -> Double {
        amount.nonNegative
    }
    
    /// Приводит курс к неотрицательному значению.
    private func normalizedRateLocalToBase(_ rate: Double) -> Double {
        rate.nonNegative
    }
    
    /// Приводит корректировку курса к неотрицательному значению.
    private func normalizedExchangeAdjustment(_ adjustment: Double) -> Double {
        adjustment.nonNegative
    }
}
