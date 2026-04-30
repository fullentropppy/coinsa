//
//  AppSettings.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    // MARK: - Свойства

    var id: UUID = UUID()
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    var baseCurrencyCode: String = ""
    var exchangeAdjustment: Double = 0
    
    // MARK: - Инициализация

    init(
        id: UUID,
        baseCurrencyCode: String,
        exchangeAdjustment: Double,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        
        self.baseCurrencyCode = baseCurrencyCode
        self.exchangeAdjustment = exchangeAdjustment
    }
}
