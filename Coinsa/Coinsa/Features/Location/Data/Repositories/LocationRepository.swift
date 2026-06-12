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
    ///   - locationCurrency: Локальная валюта.
    ///   - rateLocationToBase: Курс к основной валюте.
    ///   - exchangeAdjustment: Процентная корректировка курса.
    ///   - budget: Сумма бюджета в основной валюте.
    ///   - trip: Родительская поездка.
    func add(
        name: String,
        startDate: Date,
        endDate: Date,
        majorTimeZone: MajorTimeZone,
        locationCurrency: Currency,
        rateLocationToBase: Double,
        exchangeAdjustment: Double,
        budget: Double,
        trip: Trip
    ) {
        let now = Date()
        
        let location = Location(
            id: UUID(),
            name: name.trimmed,
            startDate: startDate,
            endDate: endDate,
            timeZoneID: majorTimeZone.id,
            locationCurrencyCode: locationCurrency.code,
            rateLocationToBase: rateLocationToBase,
            exchangeAdjustment: exchangeAdjustment,
            budget: budget,
            trip: trip,
            expenses: [],
            createdAt: now,
            updatedAt: now
        )
        
        normalizedLocationData(location)
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
    ///   - locationCurrency: Новая локальная валюта.
    ///   - rateLocationToBase: Новый курс.
    ///   - budget: Новый бюджет.
    ///   - exchangeAdjustment: Новая корректировка.
    func update(
        _ location: Location,
        name: String,
        startDate: Date,
        endDate: Date,
        majorTimeZone: MajorTimeZone,
        locationCurrency: Currency,
        rateLocationToBase: Double,
        exchangeAdjustment: Double,
        budget: Double
    ) {
        location.name = name
        location.startDate = startDate
        location.endDate = endDate
        location.timeZoneID = majorTimeZone.id
        location.locationCurrencyCode = locationCurrency.code
        location.rateLocationToBase = rateLocationToBase
        location.exchangeAdjustment = exchangeAdjustment
        location.budget = budget
        location.updatedAt = Date()
        
        normalizedLocationData(location)
        try? context.save()
    }
    
    /// Удаляет локацию.
    /// - Parameter location: Локация для удаления.
    func delete(_ location: Location) {
        context.delete(location)
        try? context.save()
    }
    
    // MARK: - Номализация
    
    /// Нормализует значения локации.
    /// - Parameter location: Локация для нормализации значений.
    private func normalizedLocationData(_ location: Location) {
        location.name = location.name.trimmed
        location.startDate = location.startDate.utcNoon
        location.endDate = location.endDate.utcNoon
        location.rateLocationToBase = location.rateLocationToBase.nonNegative
        location.exchangeAdjustment = location.exchangeAdjustment
        location.budget = location.budget.nonNegative
    }
}
