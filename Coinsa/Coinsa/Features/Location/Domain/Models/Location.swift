//
//  Location.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

/// Модель локации в рамках поездки, содержащая локальную валюту, бюджет и траты.
@Model
class Location: DateRangeProviding {
    // MARK: - Свойства
    
    /// Уникальный идентификатор локации.
    var id: UUID = UUID()
    
    /// Название локации.
    var name: String = ""
    
    /// Дата начала пребывания в локации.
    var startDate: Date = Date()
    
    /// Дата окончания пребывания в локации.
    var endDate: Date = Date()
    
    /// Идентификатор IANA часового пояса локации
    var timeZoneID: String = ""
    
    /// Трехбуквенный код ISO 4217 локальной валюты.
    var locationCurrencyCode: String = ""
    
    /// Курс локальной валюты к основной валюте поездки.
    var rateLocationToBase: Double = 0
    
    /// Корректировка к курсу обмена.
    var exchangeAdjustment: Double = 0
    
    /// Общий бюджет локации в основной валюте поездки.
    var budget: Double = 0
    
    /// Поездка, к которой относится локация.
    var trip: Trip? = nil
    
    /// Список трат в данной локации.
    /// При удалении локации все связанные расходы удаляются.
    @Relationship(deleteRule: .cascade, inverse: \Expense.location)
    var expenses: [Expense]?

    /// Дата создания записи.
    var createdAt: Date = Date()
    
    /// Дата последнего обновления записи.
    var updatedAt: Date = Date()
    
    // MARK: - Инициализация
    
    /// Создает новую локацию.
    /// - Parameters:
    ///   - id: Уникальный идентификатор.
    ///   - name: Название локации.
    ///   - startDate: Дата начала пребывания.
    ///   - endDate: Дата окончания пребывания.
    ///   - timeZoneID: Идентификатор часового пояса.
    ///   - locationCurrencyCode: Код локальной валюты.
    ///   - rateLocationToBase: Курс к основной валюте.
    ///   - exchangeAdjustment: Корректировка курса.
    ///   - budget: Сумма бюджета.
    ///   - trip: Поездка-родитель.
    ///   - expenses: Список расходов.
    ///   - createdAt: Дата создания.
    ///   - updatedAt: Дата обновления.
    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        timeZoneID: String,
        locationCurrencyCode: String,
        rateLocationToBase: Double,
        exchangeAdjustment: Double,
        budget: Double,
        trip: Trip,
        expenses: [Expense],
        createdAt: Date,
        updatedAt: Date,
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.timeZoneID = timeZoneID
        self.locationCurrencyCode = locationCurrencyCode
        self.rateLocationToBase = rateLocationToBase
        self.exchangeAdjustment = exchangeAdjustment
        self.budget = budget
        self.trip = trip
        self.expenses = expenses
    }
}
