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
    
    private let defaults: UserDefaults
    
    // MARK: - Параметры учета
    
    var homeCurrency: Currency {
        get {
            defaults.string(forKey: UserDefaultsKey.homeCurrency)
                .flatMap { Currency(rawValue: $0) } ?? .defaultValue
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.homeCurrency) }
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
    
    // MARK: - Экран «Сегодня»

    var showsLocationBudgetOnOverspend: Bool {
        get { defaults.bool(forKey: UserDefaultsKey.showsLocationBudgetOnOverspend) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.showsLocationBudgetOnOverspend) }
    }

    /// Порог перерасхода в процентах, от 0 до 100 с шагом 5.
    var todayBudgetOverspendThreshold: Double {
        get {
            let value = defaults.double(forKey: UserDefaultsKey.todayBudgetOverspendThreshold)
            guard value.isFinite else { return 20 }
            return (min(max(value, 0), 100) / 5).rounded() * 5
        }
        set { defaults.set(newValue, forKey: UserDefaultsKey.todayBudgetOverspendThreshold) }
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
    
    var converterBaseCurrency: Currency {
        get {
            defaults.string(forKey: UserDefaultsKey.converterBaseCurrency)
                .flatMap { Currency(rawValue: $0) } ?? .usd
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.converterBaseCurrency) }
    }

    var converterQuoteCurrency: Currency {
        get {
            defaults.string(forKey: UserDefaultsKey.converterQuoteCurrency)
                .flatMap { Currency(rawValue: $0) } ?? .rub
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.converterQuoteCurrency) }
    }

    var converterAmount: Double {
        get { defaults.double(forKey: UserDefaultsKey.converterAmount) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.converterAmount) }
    }
    
    // MARK: - Инициализация
    
    /// Инициализирует переданное хранилище настроек и регистрирует значения по умолчанию.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            UserDefaultsKey.fetchExpenseExchangeRateOnline: true,
            UserDefaultsKey.detectPlaceOfExpense: true,
            UserDefaultsKey.showsLocationBudgetOnOverspend: true,
            UserDefaultsKey.todayBudgetOverspendThreshold: 20.0
        ])
    }
}

// MARK: - Приватные типы

/// Ключи для хранения значений в UserDefaults.
private enum UserDefaultsKey {
    static let homeCurrency = "homeCurrency"
    static let exchangeAdjustment = "exchangeAdjustment"
    static let fetchExpenseExchangeRateOnline = "fetchExpenseExchangeRateOnline"
    static let detectPlaceOfExpense = "detectPlaceOfExpense"
    static let showsLocationBudgetOnOverspend = "showsLocationBudgetOnOverspend"
    static let todayBudgetOverspendThreshold = "todayBudgetOverspendThreshold"
    static let appAppearance = "appAppearance"
    static let isFloatingButtonOnLeft = "isFloatingButtonOnLeft"
    static let selectedLocationID = "selectedLocationID"
    static let selectedPaymentMethod = "selectedPaymentMethod"
    static let converterBaseCurrency = "converterBaseCurrency"
    static let converterQuoteCurrency = "converterQuoteCurrency"
    static let converterAmount = "converterAmount"
}
