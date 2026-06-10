//
//  Expense.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 28.02.2026.
//

import Foundation
import SwiftData

/// Модель траты в определенной локации с указанием суммы, категории и способа оплаты.
@Model
class Expense {
    // MARK: - Свойства
    
    /// Уникальный идентификатор траты.
    var id: UUID = UUID()
    
    /// Дата траты.
    var date: Date = Date()
    
    /// Сумма траты в основной валюте поездки.
    var baseAmount: Double = 0
    
    /// Трехбуквенный код ISO 4217 валюты траты.
    var expenseCurrencyCode: String = ""
    
    /// Курс валюты траты к основной в момент траты.
    var rateExpenseToBase: Double = 0
    
    /// Курс валюты траты к валюте локации в момент траты.
    var rateExpenseToLocation: Double = 0
    
    /// Сырое значение способа оплаты.
    var paymentMethodRaw: String = ""
    
    /// Корректировка к курсу обмена.
    var exchangeAdjustment: Double = 0
    
    /// Сырое значение категории траты.
    var categoryRaw: String = ""
    
    /// Сырое значение подкатегории траты.
    var subcategoryRaw: String = ""
    
    /// Локация, в которой совершена трата.
    var location: Location?
    
    /// Комментарий к трате.
    var comment: String?

    /// Дата создания записи.
    var createdAt: Date = Date()
    
    /// Дата последнего обновления записи.
    var updatedAt: Date = Date()
    
    // MARK: - Инициализация
    
    /// Создает новую трату.
    /// - Parameters:
    ///   - id: Уникальный идентификатор.
    ///   - date: Дата траты.
    ///   - baseAmount: Сумма в основной валюте.
    ///   - expenseCurrencyCode: Код валюты траты.
    ///   - rateExpenseToBase: Курс валюты траты к основной.
    ///   - rateExpenseToLocation: Курс валюты траты к валюте локации.
    ///   - paymentMethodRaw: Сырое значение способа оплаты.
    ///   - exchangeAdjustment: Корректировка курса.
    ///   - categoryRaw: Сырое значение категории.
    ///   - categoryRaw: Сырое значение подкатегории.
    ///   - location: Локация траты.
    ///   - comment: Комментарий.
    ///   - createdAt: Дата создания.
    ///   - updatedAt: Дата обновления.
    init(
        id: UUID,
        date: Date,
        baseAmount: Double,
        expenseCurrencyCode: String,
        rateExpenseToBase: Double,
        rateExpenseToLocation: Double,
        paymentMethodRaw: String,
        exchangeAdjustment: Double,
        categoryRaw: String,
        subcategoryRaw: String,
        location: Location,
        comment: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.date = date
        self.baseAmount = baseAmount
        self.expenseCurrencyCode = expenseCurrencyCode
        self.rateExpenseToBase = rateExpenseToBase
        self.rateExpenseToLocation = rateExpenseToLocation
        self.paymentMethodRaw = paymentMethodRaw
        self.exchangeAdjustment = exchangeAdjustment
        self.categoryRaw = categoryRaw
        self.subcategoryRaw = subcategoryRaw
        self.location = location
        self.comment = comment
    }
}
