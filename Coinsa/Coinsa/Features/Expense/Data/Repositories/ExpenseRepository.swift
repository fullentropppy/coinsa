//
//  ExpenseRepository.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.03.2026.
//

import Foundation
import SwiftData

/// Репозиторий для выполнения операций CRUD над тратами.
@MainActor
struct ExpenseRepository {
    // MARK: - Свойства
    
    let context: ModelContext
    
    // MARK: - Операции с хранилищем
    
    /// Создает новую трату.
    /// - Parameters:
    ///   - date: Дата совершения траты.
    ///   - homeAmount: Сумма в домашней валюте.
    ///   - expenseCurrency: Валюта траты.
    ///   - rateExpenseToHome: Курс валюты траты к домашней.
    ///   - rateExpenseToLocation: Курс к валюте локации; для общей траты определяется из курса к домашней валюте.
    ///   - paymentMethod: Способ оплаты.
    ///   - exchangeAdjustment: Процентная корректировка курса.
    ///   - category: Категория траты.
    ///   - subcategory: Подкатегория траты.
    ///   - location: Владелец траты локации или nil для общей траты.
    ///   - trip: Владелец общей траты или nil для траты локации.
    ///   - latitude: Географическая широта места траты.
    ///   - longitude: Географическая долгота места траты.
    ///   - horizontalAccuracy: Точность определения координат в метрах.
    ///   - comment: Комментарий (опционально).
    ///   - isExcludedFromDailySpending: Исключать трату из дневной суммы.
    ///   - expectedHomeCurrency: Домашняя валюта черновика для проверки перед записью.
    ///   - copiedDateMetadata: Исходный момент и пояс копии, сохраняемые при неизмененной дате.
    func add(
        date: Date,
        homeAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToHome: Double,
        rateExpenseToLocation: Double = 1,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        location: Location? = nil,
        trip: Trip? = nil,
        latitude: Double?,
        longitude: Double?,
        horizontalAccuracy: Double?,
        comment: String?,
        isExcludedFromDailySpending: Bool = false,
        expectedHomeCurrency: Currency? = nil,
        copiedDateMetadata: ExpenseCopyDateMetadata? = nil
    ) throws {
        try validateOwner(location: location, trip: trip)
        guard expectedHomeCurrency.map({ $0 == (location?.trip ?? trip)?.homeCurrency }) != false else {
            throw ExpenseRepositoryError.homeCurrencyChanged
        }

        try saveChanges {
            let now = Date()
        
            let expense = Expense(
                id: UUID(),
                date: date,
                actualDate: date,
                timeZoneID: "",
                homeAmount: homeAmount,
                expenseCurrencyCode: expenseCurrency.code,
                rateExpenseToHome: rateExpenseToHome,
                rateExpenseToLocation: rateExpenseToLocation,
                paymentMethodRaw: paymentMethod.rawValue,
                exchangeAdjustment: exchangeAdjustment,
                categoryRaw: category.rawValue,
                subcategoryRaw: subcategory.rawValue,
                location: location,
                trip: trip,
                latitude: latitude,
                longitude: longitude,
                horizontalAccuracy: horizontalAccuracy,
                comment: comment,
                isExcludedFromDailySpending: isExcludedFromDailySpending,
                createdAt: now,
                updatedAt: now
            )
        
            normalizeExpenseData(expense, updatesDateMetadata: true)
            if let copiedDateMetadata, expense.civilDateTime == copiedDateMetadata.civilDateTime {
                expense.actualDate = copiedDateMetadata.actualDate
                expense.timeZoneID = copiedDateMetadata.timeZoneID
            }
            context.insert(expense)
        }
    }
    
    /// Обновляет существующую трату.
    /// - Parameters:
    ///   - expense: Трата для обновления.
    ///   - date: Новая дата.
    ///   - homeAmount: Новая сумма в домашней валюте.
    ///   - expenseCurrency: Новая валюта траты.
    ///   - rateExpenseToHome: Новый курс валюты траты к домашней.
    ///   - rateExpenseToLocation: Новый курс валюты траты к валюте локации.
    ///   - paymentMethod: Новый способ оплаты.
    ///   - exchangeAdjustment: Новая корректировка.
    ///   - category: Новая категория.
    ///   - subcategory: Новая подкатегория.
    ///   - latitude: Новая географическая широта места траты.
    ///   - longitude: Новая географическая долгота места траты.
    ///   - horizontalAccuracy: Новая точность определения координат в метрах.
    ///   - comment: Новый комментарий.
    ///   - isExcludedFromDailySpending: Исключать трату из дневной суммы.
    ///   - expectedHomeCurrency: Домашняя валюта черновика для проверки перед записью.
    ///   - moveContext: Снимок переноса или nil при обычном редактировании.
    func update(
        _ expense: Expense,
        date: Date,
        homeAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToHome: Double,
        rateExpenseToLocation: Double = 1,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        latitude: Double?,
        longitude: Double?,
        horizontalAccuracy: Double?,
        comment: String?,
        isExcludedFromDailySpending: Bool,
        expectedHomeCurrency: Currency? = nil,
        moveContext: ExpenseMoveContext? = nil
    ) throws {
        guard expense.modelContext === context, !expense.isDeleted else {
            throw ExpenseRepositoryError.expenseUnavailable
        }
        try validateOwner(location: expense.location, trip: expense.trip)
        guard expectedHomeCurrency.map({ $0 == expense.owningTrip?.homeCurrency }) != false else {
            throw ExpenseRepositoryError.homeCurrencyChanged
        }

        if let moveContext {
            try validateOwner(location: moveContext.location, trip: moveContext.trip)
            guard moveContext.expense === expense,
                  expense.updatedAt == moveContext.sourceUpdatedAt,
                  expense.owningTrip === (moveContext.location?.trip ?? moveContext.trip),
                  moveContext.location?.locationCurrency == moveContext.locationCurrency else {
                throw ExpenseRepositoryError.moveConflict
            }
            let targetRate = moveContext.location == nil ? rateExpenseToHome : rateExpenseToLocation
            guard targetRate.isFinite, targetRate > 0 else {
                throw ExpenseRepositoryError.invalidMoveRate
            }
        }

        try saveChanges {
            let hasDateChanged = CivilDateTime(date) != expense.civilDateTime

            if let moveContext {
                expense.location = moveContext.location
                expense.trip = moveContext.trip
            }
            expense.storedDate = date
            expense.baseAmount = homeAmount
            expense.expenseCurrencyCode = expenseCurrency.code
            expense.rateExpenseToBase = rateExpenseToHome
            expense.rateExpenseToLocation = rateExpenseToLocation
            expense.paymentMethodRaw = paymentMethod.rawValue
            expense.exchangeAdjustment = exchangeAdjustment
            expense.categoryRaw = category.rawValue
            expense.subcategoryRaw = subcategory.rawValue
            expense.latitude = latitude
            expense.longitude = longitude
            expense.horizontalAccuracy = horizontalAccuracy
            expense.comment = comment
            expense.isExcludedFromDailySpending = expense.isGeneralExpense ? false : isExcludedFromDailySpending
            expense.updatedAt = Date()

            normalizeExpenseData(expense, updatesDateMetadata: hasDateChanged)
        }
    }

    /// Проверяет единственного владельца и доступность его поездки в текущем контексте.
    /// - Parameters:
    ///   - location: Локация обычной траты.
    ///   - trip: Поездка общей траты.
    private func validateOwner(location: Location?, trip: Trip?) throws {
        guard (location != nil) != (trip != nil) else {
            throw ExpenseRepositoryError.expenseUnavailable
        }
        if let location {
            guard location.modelContext === context, !location.isDeleted,
                  let trip = location.trip, trip.modelContext === context, !trip.isDeleted else {
                throw ExpenseRepositoryError.locationUnavailable
            }
        } else if let trip, trip.modelContext !== context || trip.isDeleted {
            throw ExpenseRepositoryError.tripUnavailable
        }
    }
    
    /// Удаляет трату.
    /// - Parameter expense: Трата для удаления.
    func delete(_ expense: Expense) throws {
        try delete([expense])
    }

    /// Удаляет выбранные траты одной операцией и восстанавливает их при ошибке записи.
    /// - Parameter expenses: Траты из текущего контекста.
    func delete(_ expenses: [Expense]) throws {
        guard expenses.allSatisfy({ $0.modelContext === context && !$0.isDeleted }) else {
            throw ExpenseRepositoryError.expenseUnavailable
        }

        try saveChanges {
            for expense in expenses {
                context.delete(expense)
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
    
    // MARK: - Нормализация значений
    
    /// Нормализует значения траты.
    /// - Parameters:
    ///   - expense: Трата для нормализации значений.
    ///   - updatesDateMetadata: Обновлять момент и пояс при создании или изменении даты и времени.
    private func normalizeExpenseData(_ expense: Expense, updatesDateMetadata: Bool) {
        expense.storedDate = expense.storedDate.storedCivilDateTime(using: .utc)
        
        if updatesDateMetadata {
            let timeZone = TimeZone.current
            expense.actualDate = expense.civilDateTime.actualDate(using: timeZone)
            expense.timeZoneID = timeZone.identifier
        }
        
        expense.baseAmount = expense.baseAmount.nonNegative
        expense.rateExpenseToBase = expense.rateExpenseToBase.nonNegative
        expense.rateExpenseToLocation = normalizedRateExpenseToLocation(of: expense)
        expense.exchangeAdjustment = expense.exchangeAdjustment.nonNegative
        expense.comment = normalizedComment(of: expense)
    }
    
    /// Нормализует значение курса обмена валюты траты к валюте локации.
    /// - Parameter expense: Трата-источник данных.
    private func normalizedRateExpenseToLocation(of expense: Expense) -> Double {
        if expense.isGeneralExpense {
            expense.rateExpenseToHome.nonNegative
        } else if expense.expenseCurrency == expense.locationCurrency {
            1
        } else {
            expense.rateExpenseToLocation.nonNegative
        }
    }
    
    /// Очищает комментарий от лишних пробелов.
    /// - Parameter expense: Трата-источник данных.
    private func normalizedComment(of expense: Expense) -> String? {
        if let comment = expense.comment, !comment.isBlank {
            comment.trimmed
        } else {
            nil
        }
    }
}

// MARK: - Ошибки

/// Причина недоступности данных для операции с тратой.
enum ExpenseRepositoryError: LocalizedError {
    case locationUnavailable
    case expenseUnavailable
    case tripUnavailable
    case homeCurrencyChanged
    case moveConflict
    case invalidMoveRate

    var errorDescription: String? {
        switch self {
        case .locationUnavailable:
            String(localized: .expenseEditorUnavailableMessage)
        case .expenseUnavailable:
            String(localized: .expenseStorageErrorUnavailableMessage)
        case .tripUnavailable:
            String(localized: .tripEditorUnavailableMessage)
        case .homeCurrencyChanged:
            String(localized: .expenseEditorErrorHomeCurrencyChangedMessage)
        case .moveConflict:
            String(localized: .expenseMoveErrorChangedMessage)
        case .invalidMoveRate:
            String(localized: .expenseMoveErrorRateMessage)
        }
    }
}
