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
    ///   - baseCurrency: Основная валюта.
    func add(
        name: String,
        startDate: Date,
        endDate: Date,
        baseCurrency: Currency
    ) {
        let now = Date()
        
        let trip = Trip(
            id: UUID(),
            name: name,
            startDate: startDate,
            endDate: endDate,
            baseCurrencyCode: baseCurrency.code,
            locations: [],
            createdAt: now,
            updatedAt: now
        )
        
        normalizeTripData(trip)
        context.insert(trip)
        try? context.save()
    }
    
    /// Обновляет существующую поездку.
    /// - Parameters:
    ///   - trip: Поездка для обновления.
    ///   - name: Новое название.
    ///   - startDate: Новая дата начала.
    ///   - endDate: Новая дата окончания.
    ///   - baseCurrency: Новая основная валюта.
    
    func update(
        _ trip: Trip,
        name: String,
        startDate: Date,
        endDate: Date,
        baseCurrency: Currency
    ) {
        trip.name = name
        trip.storedStartDate = startDate
        trip.storedEndDate = endDate
        trip.baseCurrencyCode = baseCurrency.code
        trip.updatedAt = Date()

        normalizeTripData(trip)
        try? context.save()
    }
    
    /// Удаляет поездку.
    /// - Parameter trip: Поездка для удаления.
    func delete(_ trip: Trip) {
        context.delete(trip)
        try? context.save()
    }
    
    // MARK: - Номализация
    
    /// Нормализует значения поездки.
    /// - Parameter trip: Поездка для нормализации значений.
    private func normalizeTripData(_ trip: Trip) {
        trip.name = trip.name.trimmed
        trip.storedStartDate = trip.storedStartDate.storedPlainDate(using: .utc)
        trip.storedEndDate = trip.storedEndDate.storedPlainDate(using: .utc)
    }
}
