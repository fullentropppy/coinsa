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
    ///   - rateExpenseToLocation: Курс валюты траты к валюте локации.
    ///   - paymentMethod: Способ оплаты.
    ///   - exchangeAdjustment: Процентная корректировка курса.
    ///   - category: Категория траты.
    ///   - subcategory: Подкатегория траты.
    ///   - location: Локация, в которой совершена трата.
    ///   - latitude: Географическая широта места траты.
    ///   - longitude: Географическая долгота места траты.
    ///   - horizontalAccuracy: Точность определения координат в метрах.
    ///   - comment: Комментарий (опционально).
    func add(
        date: Date,
        homeAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToHome: Double,
        rateExpenseToLocation: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        location: Location,
        latitude: Double?,
        longitude: Double?,
        horizontalAccuracy: Double?,
        comment: String?
    ) {
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
            latitude: latitude,
            longitude: longitude,
            horizontalAccuracy: horizontalAccuracy,
            comment: comment,
            createdAt: now,
            updatedAt: now
        )
        
        normalizeExpenseData(expense, updatesDateMetadata: true)
        context.insert(expense)
        try? context.save()
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
    func update(
        _ expense: Expense,
        date: Date,
        homeAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToHome: Double,
        rateExpenseToLocation: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        latitude: Double?,
        longitude: Double?,
        horizontalAccuracy: Double?,
        comment: String?
    ) {
        let hasDateChanged = CivilDateTime(date) != expense.civilDateTime

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
        expense.updatedAt = Date()
        
        normalizeExpenseData(expense, updatesDateMetadata: hasDateChanged)
        try? context.save()
    }
    
    /// Удаляет трату.
    /// - Parameter expense: Трата для удаления.
    func delete(_ expense: Expense) {
        context.delete(expense)
        try? context.save()
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
        if expense.expenseCurrency == expense.locationCurrency {
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
