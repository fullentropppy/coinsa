//
//  Location.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

/// Модель локации в рамках поездки, содержащая валюту локации, бюджет и траты.
@Model
class Location: DateRangeProviding {
    // MARK: - Свойства
    
    /// Уникальный идентификатор локации.
    var id: UUID = UUID()
    
    /// Название локации.
    var name: String = ""
    
    /// Дата начала пребывания в локации в формате хранения.
    var storedStartDate: Date = Date()
    
    /// Дата окончания пребывания в локации в формате хранения.
    var storedEndDate: Date = Date()
    
    /// Трехбуквенный код ISO 4217 валюты локации.
    var locationCurrencyCode: String = ""
    
    /// Курс валюты локации к домашней валюте поездки.
    /// TODO: rateLocationToBase - legacy название, поменять на rateLocationToHome.
    var rateLocationToBase: Double = 0
    
    /// Корректировка к курсу обмена.
    var exchangeAdjustment: Double = 0
    
    /// Общий бюджет локации в домашней валюте поездки.
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
    ///   - locationCurrencyCode: Код валюты локации.
    ///   - rateLocationToBase: Курс к домашней валюте.
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
        locationCurrencyCode: String,
        rateLocationToHome: Double,
        exchangeAdjustment: Double,
        budget: Double,
        trip: Trip,
        expenses: [Expense],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.name = name
        self.storedStartDate = startDate
        self.storedEndDate = endDate
        self.locationCurrencyCode = locationCurrencyCode
        self.rateLocationToBase = rateLocationToHome
        self.exchangeAdjustment = exchangeAdjustment
        self.budget = budget
        self.trip = trip
        self.expenses = expenses
    }
}
