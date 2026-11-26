//
//  DataTransferValidation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.11.2026.
//

import Foundation

/// Проверки целостности переносимого графа без исправления исходных значений.
nonisolated enum DataTransferValidation {
    // MARK: - Проверка снимка

    /// Проверяет схему, идентификаторы, родителей и значения всего графа, включая конечность расчетов.
    /// - Parameter archive: Исходный или объединенный снимок, который нельзя исправлять при проверке.
    static func validate(_ archive: DataTransferArchive) throws {
        guard archive.format == "ru.dgritsenko.coinsa.archive", archive.schemaVersion == 1 else {
            throw DataTransferError.unsupportedVersion
        }
        let allIDs = archive.trips.map(\.id) + archive.locations.map(\.id) + archive.expenses.map(\.id)
        guard Set(allIDs).count == allIDs.count else { throw DataTransferError.duplicateID }
        let tripIDs = Set(archive.trips.map(\.id))
        let locationIDs = Set(archive.locations.map(\.id))
        guard archive.locations.allSatisfy({ tripIDs.contains($0.tripID) }),
              archive.expenses.allSatisfy({ expense in
                  if let locationID = expense.locationID {
                      return expense.tripID == nil && locationIDs.contains(locationID)
                  }
                  return expense.tripID.map(tripIDs.contains) == true
              }) else {
            throw DataTransferError.invalidRelationships
        }
        guard validDate(archive.exportedAt) else {
            throw DataTransferError.invalidValues
        }
        let trips = Dictionary(uniqueKeysWithValues: archive.trips.map { ($0.id, $0) })
        let locations = Dictionary(uniqueKeysWithValues: archive.locations.map { ($0.id, $0) })
        for trip in archive.trips {
            try validateDates(start: trip.startDate, end: trip.endDate)
            guard !trip.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  Currency(rawValue: trip.homeCurrencyCode) != nil,
                  nonNegative(trip.generalExpensesBudget) else {
                throw DataTransferError.invalidValues
            }
            try validateMetadata(createdAt: trip.createdAt, updatedAt: trip.updatedAt)
        }
        for location in archive.locations {
            try validateDates(start: location.startDate, end: location.endDate)
            guard !location.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  Currency(rawValue: location.locationCurrencyCode) != nil,
                  positive(location.rateLocationToHome), nonNegative(location.budget),
                  nonNegative(location.exchangeAdjustment) else {
                throw DataTransferError.invalidValues
            }
            try validateMetadata(createdAt: location.createdAt, updatedAt: location.updatedAt)
        }
        for expense in archive.expenses {
            _ = try DataTransferCodec.date(expense.civilDateTime, includesTime: true)
            let tripID = expense.tripID ?? expense.locationID.flatMap { locations[$0]?.tripID }
            guard Currency(rawValue: expense.expenseCurrencyCode) != nil,
                  PaymentMethod(rawValue: expense.paymentMethodRaw) != nil,
                  let category = ExpenseCategory(rawValue: expense.categoryRaw),
                  let subcategory = ExpenseSubcategory(rawValue: expense.subcategoryRaw),
                  category.subcategories.contains(subcategory),
                  nonNegative(expense.homeAmount), positive(expense.rateExpenseToHome),
                  positive(expense.rateExpenseToLocation), nonNegative(expense.exchangeAdjustment),
                  expense.actualDate.map(validDate) != false,
                  let tripID, let trip = trips[tripID],
                  expense.tripID == nil || expense.rateExpenseToLocation == expense.rateExpenseToHome,
                  let homeCurrency = Currency(rawValue: trip.homeCurrencyCode),
                  let expenseCurrency = Currency(rawValue: expense.expenseCurrencyCode),
                  let paymentMethod = PaymentMethod(rawValue: expense.paymentMethodRaw) else {
                throw DataTransferError.invalidValues
            }
            let calculation = ExpenseCalculationContext(
                homeAmount: expense.homeAmount, homeCurrency: homeCurrency, expenseCurrency: expenseCurrency,
                rateExpenseToHome: expense.rateExpenseToHome, rateExpenseToLocation: expense.rateExpenseToLocation,
                paymentMethod: paymentMethod, exchangeAdjustment: expense.exchangeAdjustment
            )
            for mode in [ExchangeRateMode.actual, .effective] {
                for currency in [CurrencyContext.home, .location, .expense] {
                    guard nonNegative(calculation.amount(in: currency, using: mode)),
                          positive(calculation.exchangeRate(from: .home, to: currency, using: mode)) else {
                        throw DataTransferError.invalidValues
                    }
                }
            }
            switch (expense.latitude, expense.longitude) {
            case (nil, nil):
                guard expense.horizontalAccuracy == nil else { throw DataTransferError.invalidValues }
            case let (.some(latitude), .some(longitude)):
                guard latitude.isFinite, longitude.isFinite,
                      (-90...90).contains(latitude), (-180...180).contains(longitude),
                      expense.horizontalAccuracy.map(nonNegative) != false else {
                    throw DataTransferError.invalidValues
                }
            default:
                throw DataTransferError.invalidValues
            }
            try validateMetadata(createdAt: expense.createdAt, updatedAt: expense.updatedAt)
        }
    }

    // MARK: - Даты и метаданные

    /// Проверяет существование календарных дней и порядок границ диапазона.
    /// - Parameters:
    ///   - start: Начальный день в формате файла.
    ///   - end: Конечный день в формате файла.
    private static func validateDates(start: String, end: String) throws {
        guard try DataTransferCodec.date(start) <= DataTransferCodec.date(end) else {
            throw DataTransferError.invalidValues
        }
    }

    /// Проверяет представимость метаданных без требования монотонности часов устройства.
    /// - Parameters:
    ///   - createdAt: Исходная дата создания записи.
    ///   - updatedAt: Исходная дата последнего изменения записи.
    private static func validateMetadata(createdAt: Date, updatedAt: Date) throws {
        guard validDate(createdAt), validDate(updatedAt) else {
            throw DataTransferError.invalidValues
        }
    }

    /// Ограничивает абсолютные моменты конечными значениями в диапазоне годов 0001–9999.
    /// - Parameter date: Проверяемый фактический момент или метаданные записи.
    /// - Returns: Можно ли безопасно хранить и отображать значение.
    private static func validDate(_ date: Date) -> Bool {
        let seconds = date.timeIntervalSinceReferenceDate
        return seconds.isFinite && (-63_113_904_000...252_423_993_599).contains(seconds)
    }

    // MARK: - Числовые значения

    /// Проверяет строго положительное конечное значение курса.
    /// - Parameter value: Курс или вычисленный коэффициент конвертации.
    /// - Returns: Допустимо ли значение для конвертации без нулевого делителя.
    private static func positive(_ value: Double) -> Bool {
        value.isFinite && value > 0
    }

    /// Проверяет конечное неотрицательное значение без округления и исправления.
    /// - Parameter value: Сумма, корректировка курса или точность координат.
    /// - Returns: Соответствует ли значение допустимому диапазону.
    private static func nonNegative(_ value: Double) -> Bool {
        value.isFinite && value >= 0
    }
}
