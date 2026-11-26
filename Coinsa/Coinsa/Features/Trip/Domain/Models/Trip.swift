//
//  Trip.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation
import SwiftData

/// Модель поездки, содержащая информацию о временных рамках и локациях.
@Model
class Trip: DateRangeProviding {
    // MARK: - Свойства
    
    /// Уникальный идентификатор поездки.
    var id: UUID = UUID()
    
    /// Название поездки.
    var name: String = ""
    
    /// Дата начала поездки в формате хранения.
    var storedStartDate: Date = Date()
    
    /// Дата окончания поездки в формате хранения.
    var storedEndDate: Date = Date()
    
    /// Трехбуквенный код ISO 4217 домашней валюты в которой записываются все суммы.
    /// TODO: baseCurrencyCode - legacy название, поменять на homeCurrencyCode.
    var baseCurrencyCode: String = ""

    /// Список локаций поездки.
    /// При удалении поездки все связанные локации удаляются.
    @Relationship(deleteRule: .cascade, inverse: \Location.trip)
    var locations: [Location]?

    /// Бюджет общих трат в домашней валюте поездки.
    var generalExpensesBudget: Double = 0

    /// Общие траты поездки, каскадно удаляемые вместе с ней.
    @Relationship(deleteRule: .cascade, inverse: \Expense.trip)
    var generalExpenses: [Expense]?
    
    /// Дата создания записи.
    var createdAt: Date = Date()
    
    /// Дата последнего обновления записи.
    var updatedAt: Date = Date()
    
    // MARK: - Инициализация
    
    /// Создает новую поездку.
    /// - Parameters:
    ///   - id: Уникальный идентификатор.
    ///   - name: Название поездки.
    ///   - startDate: Дата начала.
    ///   - endDate: Дата окончания.
    ///   - homeCurrencyCode: Код домашней валюты.
    ///   - locations: Список локаций.
    ///   - generalExpensesBudget: Бюджет общих трат в домашней валюте; по умолчанию ноль.
    ///   - createdAt: Дата создания.
    ///   - updatedAt: Дата обновления.
    init(
        id: UUID,
        name: String,
        startDate: Date,
        endDate: Date,
        homeCurrencyCode: String,
        locations: [Location],
        generalExpensesBudget: Double = 0,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.name = name
        self.storedStartDate = startDate
        self.storedEndDate = endDate
        self.baseCurrencyCode = homeCurrencyCode
        self.locations = locations
        self.generalExpensesBudget = generalExpensesBudget
    }
}
