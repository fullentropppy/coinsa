//
//  ExpensePreviewSample.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Исходная синтетическая покупка до конвертации и создания связей SwiftData.
struct ExpensePreviewSample {
    let date: Date
    let amount: Double
    let currency: Currency
    let timeZoneID: String
    let rateVariation: Double
    let paymentMethod: PaymentMethod
    let subcategory: ExpenseSubcategory
    let comment: String?
    let coordinate: Coordinate?

    /// Создает покупку с гражданским временем и суммой в валюте оплаты.
    /// - Parameters:
    ///   - date: Гражданские дата и время в UTC-представлении.
    ///   - amount: Сумма в валюте покупки без повторного округления после конвертации.
    ///   - currency: Фактическая валюта оплаты.
    ///   - timeZoneID: Часовой пояс места покупки, включая предварительные оплаты из дома.
    ///   - rateVariation: Множитель условного исторического курса; `1` сохраняет курс локации.
    ///   - paymentMethod: Способ оплаты.
    ///   - subcategory: Подкатегория, однозначно определяющая категорию.
    ///   - comment: Необязательное описание покупки.
    ///   - coordinate: Место покупки; `nil` оставляет трату без геопозиции.
    init(
        date: Date,
        amount: Double,
        currency: Currency,
        timeZoneID: String,
        rateVariation: Double = 1,
        paymentMethod: PaymentMethod = .cash,
        subcategory: ExpenseSubcategory,
        comment: String? = nil,
        coordinate: Coordinate? = nil
    ) {
        self.date = date
        self.amount = amount
        self.currency = currency
        self.timeZoneID = timeZoneID
        self.rateVariation = rateVariation
        self.paymentMethod = paymentMethod
        self.subcategory = subcategory
        self.comment = comment
        self.coordinate = coordinate
    }
}
