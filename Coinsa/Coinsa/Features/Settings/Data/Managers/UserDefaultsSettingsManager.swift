//
//  UserDefaultsSettingsManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import Foundation

/// Менеджер для хранения и извлечения настроек приложения в UserDefaults.
final class UserDefaultsSettingsManager {
    // MARK: - Зависимости
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Параметры учета
    
    var baseCurrency: Currency {
        get {
            defaults.string(forKey: UserDefaultsKey.baseCurrency)
                .flatMap { Currency(rawValue: $0) } ?? .defaultValue
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.baseCurrency) }
    }
    
    var exchangeAdjustment: Double {
        get { defaults.double(forKey: UserDefaultsKey.exchangeAdjustment) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.exchangeAdjustment) }
    }
    
    // MARK: - Автозагрузка/определение данных
    
    var fetchExpenseExchangeRateOnline: Bool {
        get { defaults.bool(forKey: UserDefaultsKey.fetchExpenseExchangeRateOnline) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.fetchExpenseExchangeRateOnline) }
    }
    
    var detectPlaceOfExpense: Bool {
        get { defaults.bool(forKey: UserDefaultsKey.detectPlaceOfExpense) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.detectPlaceOfExpense) }
    }
    
    // MARK: - Оформление
    
    var appAppearance: AppAppearance {
        get {
            defaults.string(forKey: UserDefaultsKey.appAppearance)
                .flatMap { AppAppearance(rawValue: $0) } ?? .system
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.appAppearance) }
    }
    
    var isFloatingButtonOnLeft: Bool {
        get { defaults.bool(forKey: UserDefaultsKey.isFloatingButtonOnLeft) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.isFloatingButtonOnLeft) }
    }
    
    // MARK: - Сохраненный выбор
    
    var selectedLocationID: UUID? {
        get {
            guard let idString = defaults.string(forKey: UserDefaultsKey.selectedLocationID) else { return nil }
            return UUID(uuidString: idString)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: UserDefaultsKey.selectedLocationID)
        }
    }
    
    var selectedPaymentMethod: PaymentMethod {
        get {
            defaults.string(forKey: UserDefaultsKey.selectedPaymentMethod)
                .flatMap { PaymentMethod(rawValue: $0) } ?? .defaultValue
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.selectedPaymentMethod) }
    }
    
    // MARK: - Инициализация
    
    /// Инициализирует хранилище настроек и заполняет значения по умолчанию.
    init() {
        defaults.register(defaults: [
            UserDefaultsKey.fetchExpenseExchangeRateOnline: true,
            UserDefaultsKey.detectPlaceOfExpense: true
        ])
    }
}

// MARK: - Приватные типы

/// Ключи для хранения значений в UserDefaults.
private enum UserDefaultsKey {
    static let baseCurrency = "baseCurrency"
    static let exchangeAdjustment = "exchangeAdjustment"
    static let fetchExpenseExchangeRateOnline = "fetchExpenseExchangeRateOnline"
    static let detectPlaceOfExpense = "detectPlaceOfExpense"
    static let appAppearance = "appAppearance"
    static let isFloatingButtonOnLeft = "isFloatingButtonOnLeft"
    static let selectedLocationID = "selectedLocationID"
    static let selectedPaymentMethod = "selectedPaymentMethod"
}
