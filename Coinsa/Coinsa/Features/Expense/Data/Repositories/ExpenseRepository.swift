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
            baseAmount: normalizedAmount(baseAmount),
            expenseCurrencyCode: expenseCurrency.code,
            rateExpenseToBase: normalizedRate(rateExpenseToBase),
            rateExpenseToLocation: normalizedRate(rateExpenseToLocation),
            paymentMethodRaw: paymentMethod.rawValue,
            exchangeAdjustment: normalizedExchangeAdjustment(exchangeAdjustment),
            categoryRaw: category.rawValue,
            subcategoryRaw: subcategory.rawValue,
            location: location,
            comment: normalizedComment(comment),
            createdAt: now,
            updatedAt: now
        )
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
        expense.baseAmount = normalizedAmount(baseAmount)
        expense.expenseCurrencyCode = expenseCurrency.code
        expense.rateExpenseToBase = normalizedRate(rateExpenseToBase)
        expense.rateExpenseToLocation = normalizedRate(rateExpenseToLocation)
        expense.paymentMethodRaw = paymentMethod.rawValue
        expense.exchangeAdjustment = normalizedExchangeAdjustment(exchangeAdjustment)
        expense.categoryRaw = category.rawValue
        expense.subcategoryRaw = subcategory.rawValue
        expense.comment = normalizedComment(comment)
        expense.updatedAt = Date()
        try? context.save()
    }
    
    /// Удаляет трату.
    /// - Parameter expense: Трата для удаления.
    func delete(_ expense: Expense) {
        context.delete(expense)
        try? context.save()
    }
    
    // MARK: - Нормализация значений
    
    /// Приводит сумму к неотрицательному значению.
    private func normalizedAmount(_ amount: Double) -> Double {
        amount.nonNegative
    }
    
    /// Приводит курс к неотрицательному значению.
    private func normalizedRate(_ rate: Double) -> Double {
        rate.nonNegative
    }
    
    /// Приводит корректирвоку курса к неотрицательному значению.
    private func normalizedExchangeAdjustment(_ adjustment: Double) -> Double {
        adjustment.nonNegative
    }
    
    /// Очищает комментарий от лишних пробелов.
    private func normalizedComment(_ comment: String?) -> String? {
        if let comment, !comment.isBlank {
            comment.trimmed
        } else {
            nil
        }
    }
}
