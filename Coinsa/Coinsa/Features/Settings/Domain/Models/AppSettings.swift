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

    @Attribute(.unique)
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    
    var baseCurrencyCode: String
    var exchangeAdjustment: Double
    
    // MARK: - Инициализация

    init(
        baseCurrencyCode: String,
        exchangeAdjustment: Double
    ) {
        let now = Date()
        
        self.id = UUID()
        self.createdAt = now
        self.updatedAt = now
        
        self.baseCurrencyCode = baseCurrencyCode
        self .exchangeAdjustment = exchangeAdjustment
    }
}
