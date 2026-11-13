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
    ///   - locationCurrency: Валюта локации.
    ///   - rateLocationToHome: Курс к домашней валюте.
    ///   - exchangeAdjustment: Процентная корректировка курса.
    ///   - budget: Сумма бюджета в домашней валюте.
    ///   - trip: Родительская поездка.
    func add(
        name: String,
        startDate: Date,
        endDate: Date,
        locationCurrency: Currency,
        rateLocationToHome: Double,
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
            locationCurrencyCode: locationCurrency.code,
            rateLocationToHome: rateLocationToHome,
            exchangeAdjustment: exchangeAdjustment,
            budget: budget,
            trip: trip,
            expenses: [],
            createdAt: now,
            updatedAt: now
        )
        
        normalizeLocationData(location)
        context.insert(location)
        try? context.save()
    }
    
    /// Обновляет существующую локацию.
    /// - Parameters:
    ///   - location: Локация для обновления.
    ///   - name: Новое название.
    ///   - startDate: Новая дата начала.
    ///   - endDate: Новая дата окончания.
    ///   - locationCurrency: Новая валюта локации.
    ///   - rateLocationToHome: Новый курс.
    ///   - budget: Новый бюджет.
    ///   - exchangeAdjustment: Новая корректировка.
    func update(
        _ location: Location,
        name: String,
        startDate: Date,
        endDate: Date,
        locationCurrency: Currency,
        rateLocationToHome: Double,
        exchangeAdjustment: Double,
        budget: Double
    ) {
        location.name = name
        location.storedStartDate = startDate
        location.storedEndDate = endDate
        location.locationCurrencyCode = locationCurrency.code
        location.rateLocationToBase = rateLocationToHome
        location.exchangeAdjustment = exchangeAdjustment
        location.budget = budget
        location.updatedAt = Date()
        
        normalizeLocationData(location)
        try? context.save()
    }
    
    /// Переносит подтвержденный остаток, сохраняя оба бюджета вместе и восстанавливая их при ошибке.
    /// - Parameters:
    ///   - source: Локация, передающая остаток бюджета.
    ///   - destination: Локация-получатель в той же поездке и контексте.
    ///   - expectedHomeAmount: Сумма, подтвержденная пользователем.
    ///   - expectedHomeCurrencyCode: Код домашней валюты, показанной при подтверждении.
    /// - Returns: Сохраненная сумма переноса в домашней валюте.
    func transferBudget(
        from source: Location,
        to destination: Location,
        expectedHomeAmount: Double,
        expectedHomeCurrencyCode: String
    ) throws -> Double {
        guard source.modelContext === context,
              destination.modelContext === context,
              !source.isDeleted,
              !destination.isDeleted,
              let trip = source.trip,
              !trip.isDeleted else {
            throw LocationBudgetTransfer.ValidationError.invalidLocations
        }

        let transfer = try LocationBudgetTransfer(
            from: source,
            to: destination,
            expectedHomeAmount: expectedHomeAmount,
            expectedHomeCurrencyCode: expectedHomeCurrencyCode
        )
        let previousSourceBudget = source.budget
        let previousDestinationBudget = destination.budget
        let previousSourceUpdatedAt = source.updatedAt
        let previousDestinationUpdatedAt = destination.updatedAt
        let now = Date()

        source.budget = transfer.sourceBudget
        destination.budget = transfer.destinationBudget
        source.updatedAt = now
        destination.updatedAt = now

        do {
            try context.save()
        } catch {
            source.budget = previousSourceBudget
            destination.budget = previousDestinationBudget
            source.updatedAt = previousSourceUpdatedAt
            destination.updatedAt = previousDestinationUpdatedAt
            throw error
        }

        return transfer.homeAmount
    }

    /// Удаляет локацию.
    /// - Parameter location: Локация для удаления.
    func delete(_ location: Location) {
        context.delete(location)
        try? context.save()
    }
    
    // MARK: - Нормализация
    
    /// Нормализует значения локации.
    /// - Parameter location: Локация для нормализации значений.
    private func normalizeLocationData(_ location: Location) {
        location.name = location.name.trimmed
        location.storedStartDate = location.storedStartDate.storedPlainDate(using: .utc)
        location.storedEndDate = location.storedEndDate.storedPlainDate(using: .utc)
        location.rateLocationToBase = location.rateLocationToBase.nonNegative
        location.exchangeAdjustment = location.exchangeAdjustment.nonNegative
        location.budget = location.budget.nonNegative
    }
}
