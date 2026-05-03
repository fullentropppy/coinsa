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
    ///   - rateLocalToBase: Курс локальной валюты к основной.
    ///   - paymentMethod: Способ оплаты.
    ///   - exchangeAdjustment: Процентная корректировка курса.
    ///   - category: Категория траты.
    ///   - location: Локация, в которой совершена трата.
    ///   - comment: Комментарий (опционально).
    func add(
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        location: Location,
        comment: String?
    ) {
        let now = Date()
        
        let expense = Expense(
            id: UUID(),
            date: date,
            baseAmount: normalizedAmount(baseAmount),
            rateLocalToBase: normalizedRateLocalToBase(rateLocalToBase),
            paymentMethodRaw: paymentMethod.rawValue,
            exchangeAdjustment: normalizedExchangeAdjustment(exchangeAdjustment),
            categoryRaw: category.rawValue,
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
    ///   - rateLocalToBase: Новый курс.
    ///   - paymentMethod: Новый способ оплаты.
    ///   - exchangeAdjustment: Новая корректировка.
    ///   - category: Новая категория.
    ///   - comment: Новый комментарий.
    func update(
        _ expense: Expense,
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethod: PaymentMethod,
        exchangeAdjustment: Double,
        category: ExpenseCategory,
        comment: String?
    ) {
        expense.date = date
        expense.baseAmount = normalizedAmount(baseAmount)
        expense.rateLocalToBase = normalizedRateLocalToBase(rateLocalToBase)
        expense.paymentMethodRaw = paymentMethod.rawValue
        expense.exchangeAdjustment = normalizedExchangeAdjustment(exchangeAdjustment)
        expense.categoryRaw = category.rawValue
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
    private func normalizedRateLocalToBase(_ rate: Double) -> Double {
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
