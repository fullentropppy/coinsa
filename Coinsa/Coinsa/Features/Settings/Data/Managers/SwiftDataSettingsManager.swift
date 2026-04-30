//
//  SwiftDataSettingsManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataSettingsManager {
    // MARK: - Зависимости
    
    private let context: ModelContext
    private(set) var settings: AppSettings
    
    // MARK: - Параметры учета
    
    var baseCurrency: Currency {
        get { Currency.from(settings.baseCurrencyCode) }
        set {
            settings.baseCurrencyCode = newValue.code
            saveSettings()
        }
    }
    
    var exchangeAdjustment: Double {
        get { settings.exchangeAdjustment }
        set {
            settings.exchangeAdjustment = newValue.nonNegative
            saveSettings()
        }
    }
    
    // MARK: - Инициализация
    
    init(context: ModelContext) {
        self.context = context
        self.settings = Self.loadSettings(from: context)
    }
    
    // MARK: - Приватные методы
    
    private static func loadSettings(from context: ModelContext) -> AppSettings {
        let defaultId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        let fetchDescriptor = FetchDescriptor<AppSettings>(
            predicate: #Predicate { $0.id == defaultId }
        )
        
        if let existing = try? context.fetch(fetchDescriptor).first {
            return existing
        }
        
        let new = AppSettings(
            id: defaultId,
            baseCurrencyCode: Currency.defaultCode,
            exchangeAdjustment: 0,
            createdAt: .now,
            updatedAt: .now
        )
        context.insert(new)
        return new
    }
    
    private func saveSettings() -> Void {
        settings.updatedAt = Date()
        try? context.save()
    }
}
