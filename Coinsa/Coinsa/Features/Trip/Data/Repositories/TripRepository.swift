//
//  TripRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

@MainActor
struct TripRepository {
    // MARK: - Свойства
    
    let context: ModelContext
    
    // MARK: - Операции с хранилищем
    
    func add(name: String, startDate: Date, endDate: Date) {
        let now = Date()
        
        let trip = Trip(
            id: UUID(),
            name: normlizedName(name),
            startDate: normalizedStartDate(startDate),
            endDate: normalizedEndDate(endDate),
            locations: [],
            createdAt: now,
            updatedAt: now
        )
        
        context.insert(trip)
        try? context.save()
    }
    
    func update(_ trip: Trip, name: String, startDate: Date, endDate: Date) {
        trip.name = normlizedName(name)
        trip.startDate = normalizedStartDate(startDate)
        trip.endDate = normalizedEndDate(endDate)
        trip.updatedAt = Date()
        try? context.save()
    }
    
    func delete(_ trip: Trip) {
        context.delete(trip)
        try? context.save()
    }
    
    // MARK: - Номализация
    
    private func normlizedName(_ name: String) -> String {
        name.trimmed
    }
    
    private func normalizedStartDate(_ startDate: Date) -> Date {
        startDate.startOfDay
    }
    
    private func normalizedEndDate(_ endDate: Date) -> Date {
        endDate.endOfDay
    }
}
