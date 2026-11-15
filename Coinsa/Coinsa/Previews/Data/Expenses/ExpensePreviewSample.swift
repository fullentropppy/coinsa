//
//  ExpensePreviewSample.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Описание синтетической траты до создания модели и связей SwiftData.
struct ExpensePreviewSample {
    let date: Date
    let homeAmount: Double
    let paymentMethod: PaymentMethod
    let exchangeAdjustment: Double?
    let category: ExpenseCategory
    let subcategory: ExpenseSubcategory
    let comment: String?
    let latitude: Double?
    let longitude: Double?
    let horizontalAccuracy: Double?

    /// Создает описание траты в валюте поездки с гражданским временем в UTC-представлении.
    /// - Parameters:
    ///   - date: Гражданские дата и время в формате хранения CivilDateTime.
    ///   - homeAmount: Сумма в домашней валюте поездки.
    ///   - paymentMethod: Способ оплаты.
    ///   - exchangeAdjustment: Корректировка курса; при `nil` используется значение локации.
    ///   - category: Категория траты.
    ///   - subcategory: Подкатегория траты.
    ///   - comment: Необязательный комментарий.
    ///   - latitude: Широта места траты.
    ///   - longitude: Долгота места траты.
    ///   - horizontalAccuracy: Точность координат в метрах.
    init(
        date: Date,
        homeAmount: Double,
        paymentMethod: PaymentMethod = .cash,
        exchangeAdjustment: Double? = nil,
        category: ExpenseCategory,
        subcategory: ExpenseSubcategory,
        comment: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        horizontalAccuracy: Double? = nil
    ) {
        self.date = date
        self.homeAmount = homeAmount
        self.paymentMethod = paymentMethod
        self.exchangeAdjustment = exchangeAdjustment
        self.category = category
        self.subcategory = subcategory
        self.comment = comment
        self.latitude = latitude
        self.longitude = longitude
        self.horizontalAccuracy = horizontalAccuracy
    }
}
