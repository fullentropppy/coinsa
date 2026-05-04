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
            name: normalizedName(name),
            startDate: normalizedStartDate(startDate),
            endDate: normalizedEndDate(endDate),
            baseCurrencyCode: baseCurrency.code,
            locations: [],
            createdAt: now,
            updatedAt: now
        )
        
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
        trip.name = normalizedName(name)
        trip.startDate = normalizedStartDate(startDate)
        trip.endDate = normalizedEndDate(endDate)
        trip.baseCurrencyCode = baseCurrency.code
        trip.updatedAt = Date()

        try? context.save()
    }
    
    /// Удаляет поездку.
    /// - Parameter trip: Поездка для удаления.
    func delete(_ trip: Trip) {
        context.delete(trip)
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
}
