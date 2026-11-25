//
//  DataTransferRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import Foundation
import SwiftData

/// Переносит данные без нормализации истории и сохраняет весь импорт одной локальной операцией.
@MainActor
struct DataTransferRepository {
    // MARK: - Свойства

    let container: ModelContainer

    // MARK: - Снимок и план импорта

    /// Читает все записи отдельным контекстом, не сохраняя незавершенные изменения основного контекста.
    /// - Returns: Проверенный полный снимок, отсортированный по UUID внутри каждого типа записей.
    func snapshot() throws -> DataTransferArchive {
        guard !container.mainContext.hasChanges else { throw DataTransferError.localChanges }
        let context = ModelContext(container)
        context.autosaveEnabled = false
        return try snapshot(in: context)
    }

    /// Сравнивает файл с актуальными локальными записями до подтверждения пользователем.
    /// - Parameter source: Снимок из выбранного файла.
    /// - Returns: План действий с проверенной целостностью итогового графа.
    func prepare(_ source: DataTransferArchive) throws -> DataTransferPlan {
        try DataTransferPlan(source: source, baseline: snapshot())
    }

    // MARK: - Сохранение импорта

    /// Повторно проверяет план и записывает все изменения одной локальной транзакцией с откатом ошибки.
    /// - Parameter plan: Подтвержденный план, связанный с исходным локальным снимком.
    func apply(_ plan: DataTransferPlan) throws {
        guard !container.mainContext.hasChanges else { throw DataTransferError.localChanges }
        let context = ModelContext(container)
        context.autosaveEnabled = false
        let current = try snapshot(in: context)
        guard plan.matches(current) else { throw DataTransferError.changedSincePreview }
        let checkedPlan = try DataTransferPlan(source: plan.source, baseline: current)
        try Task.checkCancellation()

        do {
            try context.transaction {
                var trips = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<Trip>()).map { ($0.id, $0) })
                var locations = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<Location>()).map { ($0.id, $0) })
                let expenses = Dictionary(uniqueKeysWithValues: try context.fetch(FetchDescriptor<Expense>()).map { ($0.id, $0) })

                for record in checkedPlan.trips.additions {
                    let trip = Trip(
                        id: record.id, name: record.name,
                        startDate: try DataTransferCodec.date(record.startDate),
                        endDate: try DataTransferCodec.date(record.endDate),
                        homeCurrencyCode: record.homeCurrencyCode, locations: [],
                        createdAt: record.createdAt, updatedAt: record.updatedAt
                    )
                    context.insert(trip)
                    trips[record.id] = trip
                }
                for record in checkedPlan.trips.updates {
                    guard let trip = trips[record.id] else { throw DataTransferError.invalidRelationships }
                    trip.name = record.name
                    trip.storedStartDate = try DataTransferCodec.date(record.startDate)
                    trip.storedEndDate = try DataTransferCodec.date(record.endDate)
                    trip.baseCurrencyCode = record.homeCurrencyCode
                    trip.updatedAt = record.updatedAt
                }
                for record in checkedPlan.locations.additions {
                    guard let trip = trips[record.tripID] else { throw DataTransferError.invalidRelationships }
                    let location = Location(
                        id: record.id, name: record.name,
                        startDate: try DataTransferCodec.date(record.startDate),
                        endDate: try DataTransferCodec.date(record.endDate),
                        locationCurrencyCode: record.locationCurrencyCode,
                        rateLocationToHome: record.rateLocationToHome,
                        exchangeAdjustment: record.exchangeAdjustment, budget: record.budget,
                        trip: trip, expenses: [], createdAt: record.createdAt, updatedAt: record.updatedAt
                    )
                    context.insert(location)
                    locations[record.id] = location
                }
                for record in checkedPlan.locations.updates {
                    guard let location = locations[record.id] else { throw DataTransferError.invalidRelationships }
                    location.name = record.name
                    location.storedStartDate = try DataTransferCodec.date(record.startDate)
                    location.storedEndDate = try DataTransferCodec.date(record.endDate)
                    location.locationCurrencyCode = record.locationCurrencyCode
                    location.rateLocationToBase = record.rateLocationToHome
                    location.exchangeAdjustment = record.exchangeAdjustment
                    location.budget = record.budget
                    location.updatedAt = record.updatedAt
                }
                for record in checkedPlan.expenses.additions {
                    guard let location = locations[record.locationID] else { throw DataTransferError.invalidRelationships }
                    let expense = Expense(
                        id: record.id, date: try DataTransferCodec.date(record.civilDateTime, includesTime: true),
                        actualDate: record.actualDate ?? Date(timeIntervalSinceReferenceDate: 0),
                        timeZoneID: record.timeZoneID ?? "", homeAmount: record.homeAmount,
                        expenseCurrencyCode: record.expenseCurrencyCode,
                        rateExpenseToHome: record.rateExpenseToHome,
                        rateExpenseToLocation: record.rateExpenseToLocation,
                        paymentMethodRaw: record.paymentMethodRaw, exchangeAdjustment: record.exchangeAdjustment,
                        categoryRaw: record.categoryRaw, subcategoryRaw: record.subcategoryRaw,
                        location: location, latitude: record.latitude, longitude: record.longitude,
                        horizontalAccuracy: record.horizontalAccuracy, comment: record.comment,
                        isExcludedFromDailySpending: record.isExcludedFromDailySpending,
                        createdAt: record.createdAt, updatedAt: record.updatedAt
                    )
                    expense.actualDate = record.actualDate
                    expense.timeZoneID = record.timeZoneID
                    context.insert(expense)
                }
                for record in checkedPlan.expenses.updates {
                    guard let expense = expenses[record.id] else { throw DataTransferError.invalidRelationships }
                    expense.storedDate = try DataTransferCodec.date(record.civilDateTime, includesTime: true)
                    expense.actualDate = record.actualDate
                    expense.timeZoneID = record.timeZoneID
                    expense.baseAmount = record.homeAmount
                    expense.expenseCurrencyCode = record.expenseCurrencyCode
                    expense.rateExpenseToBase = record.rateExpenseToHome
                    expense.rateExpenseToLocation = record.rateExpenseToLocation
                    expense.paymentMethodRaw = record.paymentMethodRaw
                    expense.exchangeAdjustment = record.exchangeAdjustment
                    expense.categoryRaw = record.categoryRaw
                    expense.subcategoryRaw = record.subcategoryRaw
                    expense.latitude = record.latitude
                    expense.longitude = record.longitude
                    expense.horizontalAccuracy = record.horizontalAccuracy
                    expense.comment = record.comment
                    expense.isExcludedFromDailySpending = record.isExcludedFromDailySpending
                    expense.updatedAt = record.updatedAt
                }
            }
        } catch {
            context.rollback()
            throw error
        }
    }

    // MARK: - Подготовка переносимых записей

    /// Читает сущности независимо от обратных списков связей и отклоняет потерю календарных компонентов.
    /// - Parameter context: Отдельный контекст для последовательного чтения всех трех типов моделей.
    /// - Returns: Полный проверенный снимок с исходными числами, метаданными и связями по UUID.
    private func snapshot(in context: ModelContext) throws -> DataTransferArchive {
        let trips = try context.fetch(FetchDescriptor<Trip>())
        let locations = try context.fetch(FetchDescriptor<Location>())
        let expenses = try context.fetch(FetchDescriptor<Expense>())
        let archive = DataTransferArchive(
            exportedAt: Date(), appVersion: AppInfo.version, appBuild: AppInfo.build,
            trips: try trips.map { trip in
                let start = DataTransferCodec.dateString(trip.storedStartDate)
                let end = DataTransferCodec.dateString(trip.storedEndDate)
                guard try DataTransferCodec.date(start) == trip.storedStartDate,
                      try DataTransferCodec.date(end) == trip.storedEndDate else {
                    throw DataTransferError.invalidValues
                }
                return DataTransferArchive.TripRecord(
                    id: trip.id, name: trip.name, startDate: start, endDate: end,
                    homeCurrencyCode: trip.baseCurrencyCode, createdAt: trip.createdAt, updatedAt: trip.updatedAt
                )
            }.sorted { $0.id.uuidString < $1.id.uuidString },
            locations: try locations.map { location in
                guard let trip = location.trip, !trip.isDeleted else { throw DataTransferError.invalidRelationships }
                let start = DataTransferCodec.dateString(location.storedStartDate)
                let end = DataTransferCodec.dateString(location.storedEndDate)
                guard try DataTransferCodec.date(start) == location.storedStartDate,
                      try DataTransferCodec.date(end) == location.storedEndDate else {
                    throw DataTransferError.invalidValues
                }
                return DataTransferArchive.LocationRecord(
                    id: location.id, tripID: trip.id, name: location.name, startDate: start, endDate: end,
                    locationCurrencyCode: location.locationCurrencyCode,
                    rateLocationToHome: location.rateLocationToBase,
                    exchangeAdjustment: location.exchangeAdjustment, budget: location.budget,
                    createdAt: location.createdAt, updatedAt: location.updatedAt
                )
            }.sorted { $0.id.uuidString < $1.id.uuidString },
            expenses: try expenses.map { expense in
                guard let location = expense.location, !location.isDeleted else { throw DataTransferError.invalidRelationships }
                let civilDateTime = DataTransferCodec.dateString(expense.storedDate, includesTime: true)
                guard try DataTransferCodec.date(civilDateTime, includesTime: true) == expense.storedDate else {
                    throw DataTransferError.invalidValues
                }
                return DataTransferArchive.ExpenseRecord(
                    id: expense.id, locationID: location.id, civilDateTime: civilDateTime,
                    actualDate: expense.actualDate, timeZoneID: expense.timeZoneID,
                    homeAmount: expense.baseAmount, expenseCurrencyCode: expense.expenseCurrencyCode,
                    rateExpenseToHome: expense.rateExpenseToBase,
                    rateExpenseToLocation: expense.rateExpenseToLocation,
                    paymentMethodRaw: expense.paymentMethodRaw, exchangeAdjustment: expense.exchangeAdjustment,
                    categoryRaw: expense.categoryRaw, subcategoryRaw: expense.subcategoryRaw,
                    latitude: expense.latitude, longitude: expense.longitude,
                    horizontalAccuracy: expense.horizontalAccuracy, comment: expense.comment,
                    isExcludedFromDailySpending: expense.isExcludedFromDailySpending,
                    createdAt: expense.createdAt, updatedAt: expense.updatedAt
                )
            }.sorted { $0.id.uuidString < $1.id.uuidString }
        )
        try DataTransferValidation.validate(archive)
        return archive
    }
}
