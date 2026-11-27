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
    ) throws {
        guard trip.modelContext === context, !trip.isDeleted else {
            throw LocationRepositoryError.tripUnavailable
        }

        try saveChanges {
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
        }
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
    ) throws {
        guard location.modelContext === context, !location.isDeleted,
              let trip = location.trip, trip.modelContext === context, !trip.isDeleted else {
            throw LocationRepositoryError.tripUnavailable
        }
        guard !location.hasExpenses || location.locationCurrency == locationCurrency else {
            throw LocationRepositoryError.locationCurrencyLocked
        }

        try saveChanges {
            location.name = name
            location.storedStartDate = startDate
            location.storedEndDate = endDate
            
            if !location.hasExpenses {
                location.locationCurrencyCode = locationCurrency.code
            }
            
            location.rateLocationToBase = rateLocationToHome
            location.exchangeAdjustment = exchangeAdjustment
            location.budget = budget
            location.updatedAt = Date()
        
            normalizeLocationData(location)
        }
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

    /// Сохраняет загруженные курсы вместе, не меняя бюджеты, корректировки и сохраненные траты.
    /// - Parameters:
    ///   - updates: Курсы и снимки локаций до начала загрузки.
    ///   - trip: Поездка, которой должны по-прежнему принадлежать все локации.
    ///   - expectedHomeCurrencyCode: Домашняя валюта на момент начала загрузки.
    func updateExchangeRates(
        _ updates: [LocationExchangeRateUpdate],
        in trip: Trip,
        expectedHomeCurrencyCode: String
    ) throws {
        guard !updates.isEmpty else { return }
        guard !trip.isDeleted, trip.modelContext === context else {
            throw LocationExchangeRateUpdate.ValidationError.unavailableLocations
        }
        guard trip.baseCurrencyCode == expectedHomeCurrencyCode else {
            throw LocationExchangeRateUpdate.ValidationError.dataChanged
        }

        let today = PlainDate.today
        for update in updates {
            let location = update.target.location
            guard !location.isDeleted, location.modelContext === context, location.trip === trip else {
                throw LocationExchangeRateUpdate.ValidationError.unavailableLocations
            }
            guard location.endPlainDate >= today,
                  location.locationCurrencyCode == update.target.currencyCode,
                  location.updatedAt == update.target.updatedAt else {
                throw LocationExchangeRateUpdate.ValidationError.dataChanged
            }
            guard update.rate.isFinite, update.rate > 0 else {
                throw LocationExchangeRateUpdate.ValidationError.invalidRate
            }
        }

        let previousValues = updates.map {
            (location: $0.target.location, rate: $0.target.location.rateLocationToHome, updatedAt: $0.target.location.updatedAt)
        }
        let now = Date()
        for update in updates {
            update.target.location.rateLocationToBase = update.rate
            update.target.location.updatedAt = now
        }

        do {
            try context.save()
        } catch {
            for previous in previousValues {
                previous.location.rateLocationToBase = previous.rate
                previous.location.updatedAt = previous.updatedAt
            }
            throw error
        }
    }

    /// Удаляет локацию вместе с дочерними тратами.
    /// - Parameter location: Локация для удаления.
    func delete(_ location: Location) throws {
        try delete([location])
    }

    /// Удаляет выбранные локации одной операцией и восстанавливает их при ошибке записи.
    /// - Parameter locations: Локации из текущего контекста.
    func delete(_ locations: [Location]) throws {
        guard locations.allSatisfy({ $0.modelContext === context && !$0.isDeleted }) else {
            throw LocationRepositoryError.locationUnavailable
        }

        try saveChanges {
            for location in locations {
                context.delete(location)
            }
        }
    }

    // MARK: - Сохранение

    /// Фиксирует предыдущие изменения до операции, чтобы откат при ошибке не затронул их.
    /// - Parameter changes: Синхронные изменения, сохраняемые вместе.
    private func saveChanges(_ changes: () -> Void) throws {
        if context.hasChanges {
            try context.save()
        }

        do {
            changes()
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
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

// MARK: - Ошибки

/// Причина недоступности данных или запрета изменения валюты локации.
enum LocationRepositoryError: LocalizedError {
    case tripUnavailable
    case locationUnavailable
    case locationCurrencyLocked

    var errorDescription: String? {
        switch self {
        case .tripUnavailable:
            String(localized: .locationEditorUnavailableMessage)
        case .locationUnavailable:
            String(localized: .locationStorageErrorUnavailableMessage)
        case .locationCurrencyLocked:
            String(localized: .locationStorageErrorLocationCurrencyLockedMessage)
        }
    }
}
