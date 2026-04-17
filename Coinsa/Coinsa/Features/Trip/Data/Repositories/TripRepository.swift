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
        let trip = Trip(
            name: name,
            startDate: startDate,
            endDate: endDate,
            locations: []
        )
        
        context.insert(trip)
        try? context.save()
    }

    func update(_ trip: Trip, name: String, startDate: Date, endDate: Date) {
        trip.name = name
        trip.startDate = startDate
        trip.endDate = endDate
        try? context.save()
    }

    func delete(_ trip: Trip) {
        context.delete(trip)
        try? context.save()
    }
}
