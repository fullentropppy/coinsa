//
//  LocationRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.03.2026.
//

import Foundation
import SwiftData

@MainActor
struct LocationRepository {
    // MARK: - Свойства

    let context: ModelContext

    // MARK: - Операции с хранилищем
    
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
            createdAt: now,
            updatedAt: now
        )
        location.applyBudgets(budgetsByCategory)
        
        context.insert(location)
        try? context.save()
    }

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

    func delete(_ location: Location) {
        context.delete(location)
        try? context.save()
    }
    
    // MARK: - Номализация
    
    private func normalizedName(_ name: String) -> String {
        name.trimmed
    }
    
    private func normalizedStartDate(_ startDate: Date) -> Date {
        startDate.startOfDay
    }
    
    private func normalizedEndDate(_ endDate: Date) -> Date {
        endDate.endOfDay
    }
    
    private func normalizedAmount(_ amount: Double) -> Double {
        amount.nonNegative
    }
    
    private func normalizedRateLocalToBase(_ rate: Double) -> Double {
        rate.nonNegative
    }
    
    private func normalizedExchangeAdjustment(_ adjustment: Double) -> Double {
        adjustment.nonNegative
    }
}
