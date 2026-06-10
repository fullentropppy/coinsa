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
            startDate: normalizedStartDate(startDate),
            endDate: normalizedEndDate(endDate),
            timeZoneID: majorTimeZone.id,
            locationCurrencyCode: locationCurrency.code,
            rateLocationToBase: normalizedRateLocationToBase(rateLocationToBase),
            exchangeAdjustment: normalizedRateLocationToBase(exchangeAdjustment),
            budget: normalizedAmount(budget),
            trip: trip,
            expenses: [],
            createdAt: now,
            updatedAt: now
        )
        
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
        location.name = name.trimmed
        location.startDate = normalizedStartDate(startDate)
        location.endDate = normalizedEndDate(endDate)
        location.timeZoneID = majorTimeZone.id
        location.locationCurrencyCode = locationCurrency.code
        location.rateLocationToBase = normalizedRateLocationToBase(rateLocationToBase)
        location.exchangeAdjustment = normalizedRateLocationToBase(exchangeAdjustment)
        location.budget = normalizedAmount(budget)
        location.updatedAt = Date()
        
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
    private func normalizedRateLocationToBase(_ rate: Double) -> Double {
        rate.nonNegative
    }
    
    /// Приводит корректировку курса к неотрицательному значению.
    private func normalizedExchangeAdjustment(_ adjustment: Double) -> Double {
        adjustment.nonNegative
    }
}
