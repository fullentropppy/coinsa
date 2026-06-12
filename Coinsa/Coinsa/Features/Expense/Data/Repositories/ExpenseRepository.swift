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
    ///   - baseAmount: Сумма в основной валюте.
    ///   - expenseCurrency: Валюта траты.
    ///   - rateExpenseToBase: Курс валюты траты к основной.
    ///   - rateExpenseToLocation: Курс валюты траты к валюте локации.
    ///   - paymentMethod: Способ оплаты.
    ///   - exchangeAdjustment: Процентная корректировка курса.
    ///   - category: Категория траты.
    ///   - subcategory: Подкатегория траты.
    ///   - location: Локация, в которой совершена трата.
    ///   - comment: Комментарий (опционально).
    func add(
        date: Date,
        baseAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToBase: Double,
        rateExpenseToLocation: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        location: Location,
        comment: String?
    ) {
        let now = Date()
        
        let expense = Expense(
            id: UUID(),
            date: date,
            baseAmount: baseAmount,
            expenseCurrencyCode: expenseCurrency.code,
            rateExpenseToBase: rateExpenseToBase,
            rateExpenseToLocation: rateExpenseToLocation,
            paymentMethodRaw: paymentMethod.rawValue,
            exchangeAdjustment: exchangeAdjustment,
            categoryRaw: category.rawValue,
            subcategoryRaw: subcategory.rawValue,
            location: location,
            comment: comment,
            createdAt: now,
            updatedAt: now
        )
        
        normalizeExpenseData(expense)
        context.insert(expense)
        try? context.save()
    }
    
    /// Обновляет существующую трату.
    /// - Parameters:
    ///   - expense: Трата для обновления.
    ///   - date: Новая дата.
    ///   - baseAmount: Новая сумма в основной валюте.
    ///   - expenseCurrency: Новая валюта траты.
    ///   - rateExpenseToBase: Новый курс валюты траты к основной.
    ///   - rateExpenseToLocation: Новый курс валюты траты к валюте локации.
    ///   - paymentMethod: Новый способ оплаты.
    ///   - exchangeAdjustment: Новая корректировка.
    ///   - category: Новая категория.
    ///   - subcategory: Новая подкатегория.
    ///   - comment: Новый комментарий.
    func update(
        _ expense: Expense,
        date: Date,
        baseAmount: Double,
        expenseCurrency: Currency,
        rateExpenseToBase: Double,
        rateExpenseToLocation: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        comment: String?
    ) {
        expense.date = date
        expense.baseAmount = baseAmount
        expense.expenseCurrencyCode = expenseCurrency.code
        expense.rateExpenseToBase = rateExpenseToBase
        expense.rateExpenseToLocation = rateExpenseToLocation
        expense.paymentMethodRaw = paymentMethod.rawValue
        expense.exchangeAdjustment = exchangeAdjustment
        expense.categoryRaw = category.rawValue
        expense.subcategoryRaw = subcategory.rawValue
        expense.comment = comment
        expense.updatedAt = Date()
        
        normalizeExpenseData(expense)
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
    /// - Parameter expense: Трата для нормализации значений.
    private func normalizeExpenseData(_ expense: Expense) {
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
