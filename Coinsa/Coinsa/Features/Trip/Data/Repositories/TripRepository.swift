//
//  TripRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

/// Репозиторий для выполнения операций CRUD над поездками.
@MainActor
struct TripRepository {
    // MARK: - Свойства
    
    let context: ModelContext
    
    // MARK: - Операции с хранилищем
    
    /// Создает новую поездку.
    /// - Parameters:
    ///   - name: Название поездки.
    ///   - startDate: Дата начала.
    ///   - endDate: Дата окончания.
    ///   - homeCurrency: Домашняя валюта.
    func add(
        name: String,
        startDate: Date,
        endDate: Date,
        homeCurrency: Currency
    ) throws {
        try saveChanges {
            let now = Date()
        
            let trip = Trip(
                id: UUID(),
                name: name,
                startDate: startDate,
                endDate: endDate,
                homeCurrencyCode: homeCurrency.code,
                locations: [],
                createdAt: now,
                updatedAt: now
            )
        
            normalizeTripData(trip)
            context.insert(trip)
        }
    }
    
    /// Обновляет существующую поездку.
    /// - Parameters:
    ///   - trip: Поездка для обновления.
    ///   - name: Новое название.
    ///   - startDate: Новая дата начала.
    ///   - endDate: Новая дата окончания.
    ///   - homeCurrency: Новая домашняя валюта.
    
    func update(
        _ trip: Trip,
        name: String,
        startDate: Date,
        endDate: Date,
        homeCurrency: Currency
    ) throws {
        guard trip.modelContext === context, !trip.isDeleted else {
            throw TripRepositoryError.tripUnavailable
        }
        guard !trip.hasLocations || trip.homeCurrency == homeCurrency else {
            throw TripRepositoryError.homeCurrencyLocked
        }

        try saveChanges {
            trip.name = name
            trip.storedStartDate = startDate
            trip.storedEndDate = endDate
            if !trip.hasLocations {
                trip.baseCurrencyCode = homeCurrency.code
            }
            trip.updatedAt = Date()

            normalizeTripData(trip)
        }
    }
    
    /// Удаляет поездку.
    /// - Parameter trip: Поездка для удаления.
    func delete(_ trip: Trip) throws {
        try delete([trip])
    }

    /// Удаляет поездки с дочерними локациями и тратами одной операцией с откатом при ошибке записи.
    /// - Parameter trips: Поездки из текущего контекста.
    func delete(_ trips: [Trip]) throws {
        guard trips.allSatisfy({ $0.modelContext === context && !$0.isDeleted }) else {
            throw TripRepositoryError.tripUnavailable
        }

        try saveChanges {
            for trip in trips {
                context.delete(trip)
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
    
    /// Нормализует значения поездки.
    /// - Parameter trip: Поездка для нормализации значений.
    private func normalizeTripData(_ trip: Trip) {
        trip.name = trip.name.trimmed
        trip.storedStartDate = trip.storedStartDate.storedPlainDate(using: .utc)
        trip.storedEndDate = trip.storedEndDate.storedPlainDate(using: .utc)
    }
}

// MARK: - Ошибки

/// Причина недоступности поездки или запрета изменения её домашней валюты.
enum TripRepositoryError: LocalizedError {
    case tripUnavailable
    case homeCurrencyLocked

    var errorDescription: String? {
        switch self {
        case .tripUnavailable:
            String(localized: .tripEditorUnavailableMessage)
        case .homeCurrencyLocked:
            String(localized: .tripStorageHomeCurrencyLockedMessage)
        }
    }
}
