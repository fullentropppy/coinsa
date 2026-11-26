//
//  DataTransferPlan.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import Foundation

/// Сводка действий над отдельным типом записей.
nonisolated struct DataTransferChanges<Record: Equatable & Sendable>: Equatable, Sendable {
    // MARK: - Свойства

    var additions: [Record] = []
    var updates: [Record] = []
    var unchanged = 0
    var older = 0
}

/// Проверенный план объединения с исходным снимком для повторной проверки перед записью.
nonisolated struct DataTransferPlan: Equatable, Sendable {
    // MARK: - Свойства

    let source: DataTransferArchive
    let baseline: DataTransferArchive
    let trips: DataTransferChanges<DataTransferArchive.TripRecord>
    let locations: DataTransferChanges<DataTransferArchive.LocationRecord>
    let expenses: DataTransferChanges<DataTransferArchive.ExpenseRecord>

    // MARK: - Сводка

    var hasChanges: Bool {
        !trips.additions.isEmpty || !trips.updates.isEmpty ||
        !locations.additions.isEmpty || !locations.updates.isEmpty ||
        !expenses.additions.isEmpty || !expenses.updates.isEmpty
    }

    var unchangedCount: Int { trips.unchanged + locations.unchanged + expenses.unchanged }
    var olderCount: Int { trips.older + locations.older + expenses.older }

    // MARK: - Инициализация

    /// Проверяет исходные данные и итоговое объединение, сохраняя приоритет файла при равных датах.
    /// - Parameters:
    ///   - source: Полностью проверяемый файл импорта.
    ///   - baseline: Текущие локальные записи, отсортированные по UUID.
    init(source: DataTransferArchive, baseline: DataTransferArchive) throws {
        try DataTransferValidation.validate(baseline)
        self.source = source
        self.baseline = baseline
        let source = Self.resolveParents(source, baseline: baseline)
        try DataTransferValidation.validate(source)

        let localTrips = Dictionary(uniqueKeysWithValues: baseline.trips.map { ($0.id, $0) })
        let localLocations = Dictionary(uniqueKeysWithValues: baseline.locations.map { ($0.id, $0) })
        let localExpenses = Dictionary(uniqueKeysWithValues: baseline.expenses.map { ($0.id, $0) })
        let sourceTrips = Dictionary(uniqueKeysWithValues: source.trips.map { ($0.id, $0) })
        let sourceLocations = Dictionary(uniqueKeysWithValues: source.locations.map { ($0.id, $0) })

        for location in source.locations {
            guard localLocations[location.id].map({ $0.tripID == location.tripID }) != false else {
                throw DataTransferError.invalidRelationships
            }
        }
        for expense in source.expenses {
            guard localExpenses[expense.id].map({ local in
                let localTripID = local.tripID ?? local.locationID.flatMap { localLocations[$0]?.tripID }
                let sourceTripID = expense.tripID ?? expense.locationID.flatMap { sourceLocations[$0]?.tripID }
                return localTripID == sourceTripID
            }) != false else {
                throw DataTransferError.invalidRelationships
            }
        }

        trips = Self.classify(source.trips, local: localTrips, updatedAt: \.updatedAt, createdAt: \.createdAt, hasUpdatedAt: \.hasUpdatedAt)
        locations = Self.classify(source.locations, local: localLocations, updatedAt: \.updatedAt, createdAt: \.createdAt, hasUpdatedAt: \.hasUpdatedAt)
        let incomingExpenses = source.expenses.map { record in
            var record = record
            if let local = localExpenses[record.id] {
                if !record.hasActualDate { record.actualDate = local.actualDate }
                if !record.hasTimeZoneID { record.timeZoneID = local.timeZoneID }
            }
            record.hasActualDate = true
            record.hasTimeZoneID = true
            return record
        }
        expenses = Self.classify(incomingExpenses, local: localExpenses, updatedAt: \.updatedAt, createdAt: \.createdAt, hasUpdatedAt: \.hasUpdatedAt)

        let tripsWithLocations = Set(baseline.locations.map(\.tripID))
        let tripsWithGeneralExpenses = Set(baseline.expenses.compactMap(\.tripID))
        let locationsWithExpenses = Set(baseline.expenses.compactMap(\.locationID))
        guard trips.updates.allSatisfy({
            (!tripsWithLocations.contains($0.id) && !tripsWithGeneralExpenses.contains($0.id))
                || localTrips[$0.id]?.homeCurrencyCode == $0.homeCurrencyCode
        }), locations.updates.allSatisfy({
            !locationsWithExpenses.contains($0.id) || localLocations[$0.id]?.locationCurrencyCode == $0.locationCurrencyCode
        }) else {
            throw DataTransferError.currencyConflict
        }

        var merged = baseline
        merged.trips = Self.merge(localTrips, changes: trips)
        merged.locations = Self.merge(localLocations, changes: locations)
        merged.expenses = Self.merge(localExpenses, changes: expenses)
        try DataTransferValidation.validate(merged)
        let mergedTrips = Dictionary(uniqueKeysWithValues: merged.trips.map { ($0.id, $0) })
        let mergedLocations = Dictionary(uniqueKeysWithValues: merged.locations.map { ($0.id, $0) })
        for location in locations.additions + locations.updates {
            guard mergedTrips[location.tripID]?.homeCurrencyCode == sourceTrips[location.tripID]?.homeCurrencyCode else {
                throw DataTransferError.currencyConflict
            }
        }
        for expense in expenses.additions + expenses.updates {
            if let locationID = expense.locationID {
                guard let sourceLocation = sourceLocations[locationID],
                      let mergedLocation = mergedLocations[locationID],
                      mergedLocation.locationCurrencyCode == sourceLocation.locationCurrencyCode,
                      mergedTrips[mergedLocation.tripID]?.homeCurrencyCode == sourceTrips[sourceLocation.tripID]?.homeCurrencyCode else {
                    throw DataTransferError.currencyConflict
                }
            } else if let tripID = expense.tripID {
                guard mergedTrips[tripID]?.homeCurrencyCode == sourceTrips[tripID]?.homeCurrencyCode else {
                    throw DataTransferError.currencyConflict
                }
            }
        }
    }

    // MARK: - Проверка актуальности

    /// Сравнивает записи с исходным состоянием, исключая служебные метаданные самого экспорта.
    /// - Parameter archive: Новый локальный снимок с тем же порядком сортировки по UUID.
    /// - Returns: Соответствует ли план актуальному состоянию всех локальных записей.
    func matches(_ archive: DataTransferArchive) -> Bool {
        baseline.trips == archive.trips && baseline.locations == archive.locations && baseline.expenses == archive.expenses
    }

    // MARK: - Подготовка изменений

    /// Дополняет файл снимками существующих родителей, если в файле указаны только их UUID.
    /// - Parameters:
    ///   - source: Записи из файла с уже назначенными UUID и служебными датами.
    ///   - baseline: Локальный снимок, относительно которого пользователь подтвердит импорт.
    /// - Returns: Полный граф для общей проверки и расчета сводки.
    private static func resolveParents(_ source: DataTransferArchive, baseline: DataTransferArchive) -> DataTransferArchive {
        var resolved = source
        let locationIDs = Set(source.locations.map(\.id))
        let referencedLocations = Set(source.expenses.compactMap(\.locationID)).subtracting(locationIDs)
        resolved.locations += baseline.locations.filter { referencedLocations.contains($0.id) }
        let tripIDs = Set(source.trips.map(\.id))
        let referencedTrips = Set(resolved.locations.map(\.tripID) + source.expenses.compactMap(\.tripID)).subtracting(tripIDs)
        resolved.trips += baseline.trips.filter { referencedTrips.contains($0.id) }
        return resolved
    }

    /// Разделяет записи по действиям; отсутствие updatedAt дает файлу приоритет без изменения даты создания.
    /// - Parameters:
    ///   - incoming: Записи из файла, проверенные на уникальность UUID.
    ///   - local: Локальные записи по UUID.
    ///   - updatedAt: Поле версии для сравнения актуальности.
    ///   - createdAt: Поле даты создания, которое сохраняется из локальной записи.
    ///   - hasUpdatedAt: Передана ли дата изменения явно; при отсутствии дата не уменьшается относительно локальной.
    /// - Returns: Добавления, обновления и счетчики пропущенных записей.
    private static func classify<Record: Identifiable & Equatable & Sendable>(
        _ incoming: [Record],
        local: [UUID: Record],
        updatedAt: WritableKeyPath<Record, Date>,
        createdAt: WritableKeyPath<Record, Date>,
        hasUpdatedAt: WritableKeyPath<Record, Bool>
    ) -> DataTransferChanges<Record> where Record.ID == UUID {
        var changes = DataTransferChanges<Record>()
        for var record in incoming {
            guard let existing = local[record.id] else {
                record[keyPath: hasUpdatedAt] = true
                changes.additions.append(record)
                continue
            }
            if !record[keyPath: hasUpdatedAt] {
                record[keyPath: updatedAt] = max(record[keyPath: updatedAt], existing[keyPath: updatedAt])
            }
            record[keyPath: hasUpdatedAt] = true
            if record[keyPath: updatedAt] < existing[keyPath: updatedAt] {
                changes.older += 1
                continue
            }
            record[keyPath: createdAt] = existing[keyPath: createdAt]
            if record == existing {
                changes.unchanged += 1
            } else {
                changes.updates.append(record)
            }
        }
        return changes
    }

    /// Собирает итоговые записи для проверки связей и валют до изменения хранилища.
    /// - Parameters:
    ///   - local: Исходные локальные записи по UUID.
    ///   - changes: Проверяемые добавления и обновления.
    /// - Returns: Объединенные записи без удаления отсутствующих в файле данных.
    private static func merge<Record: Identifiable & Equatable & Sendable>(
        _ local: [UUID: Record], changes: DataTransferChanges<Record>
    ) -> [Record] where Record.ID == UUID {
        var records = local
        for record in changes.additions + changes.updates { records[record.id] = record }
        return Array(records.values)
    }
}
