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
    
    /// Курс локальной валюты к основной на момент траты.
    var rateLocalToBase: Double = 0
    
    /// Сырое значение способа оплаты.
    var paymentMethodRaw: String = ""
    
    /// Корректировка к курсу обмена.
    var exchangeAdjustment: Double = 0
    
    /// Сырое значение категории траты.
    var categoryRaw: String = ""
    
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
    ///   - rateLocalToBase: Курс локальной валюты к основной.
    ///   - paymentMethodRaw: Сырое значение способа оплаты.
    ///   - exchangeAdjustment: Корректировка курса.
    ///   - categoryRaw: Сырое значение категории.
    ///   - location: Локация траты.
    ///   - comment: Комментарий.
    ///   - createdAt: Дата создания.
    ///   - updatedAt: Дата обновления.
    init(
        id: UUID,
        date: Date,
        baseAmount: Double,
        rateLocalToBase: Double,
        paymentMethodRaw: String,
        exchangeAdjustment: Double,
        categoryRaw: String ,
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
        self.rateLocalToBase = rateLocalToBase
        self.paymentMethodRaw = paymentMethodRaw
        self.exchangeAdjustment = exchangeAdjustment
        self.categoryRaw = categoryRaw
        self.location = location
        self.comment = comment
    }
}
