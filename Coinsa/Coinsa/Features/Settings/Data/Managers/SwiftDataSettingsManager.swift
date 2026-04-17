//
//  SwiftDataSettingsManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import SwiftData

@MainActor
final class SwiftDataSettingsManager {
    // MARK: - Зависимости
    
    private let context: ModelContext
    private(set) var settings: AppSettings
    
    // MARK: - Параметры учета
    
    var baseCurrencyCode: String {
        settings.baseCurrencyCode
    }
    
    var exchangeAdjustment: Double {
        get { settings.exchangeAdjustment }
        set {
            settings.exchangeAdjustment = max(0, newValue)
            try? context.save()
        }
    }
    
    // MARK: - Инициализация
    
    init(context: ModelContext) {
        self.context = context
        self.settings = Self.loadSettings(from: context)
    }
    
    // MARK: - Приватные методы
    
    private static func loadSettings(from context: ModelContext) -> AppSettings {
        if let existing = try? context.fetch(FetchDescriptor<AppSettings>()).first {
            return existing
        }
        
        let new = AppSettings(
            baseCurrencyCode: Currency.defaultCurrencyCode,
            exchangeAdjustment: 0
        )
        context.insert(new)
        
        return new
    }
}
