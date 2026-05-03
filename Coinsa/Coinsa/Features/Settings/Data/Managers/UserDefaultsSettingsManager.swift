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
    
    // MARK: - Оформление
    
    var appAppearance: AppAppearance {
        get {
            defaults.string(forKey: UserDefaultsKey.appAppearance)
                .flatMap { AppAppearance(rawValue: $0) } ?? .system
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.appAppearance) }
    }
    
    var isAddButtonOnLeft: Bool {
        get { defaults.bool(forKey: UserDefaultsKey.isAddButtonOnLeft) }
        set { defaults.set(newValue, forKey: UserDefaultsKey.isAddButtonOnLeft) }
    }
    
    // MARK: - Сохраненный выбор
    
    var selectedLocationID: UUID? {
        get {
            guard let idString = defaults.string(forKey: UserDefaultsKey.selectedLocationId) else { return nil }
            return UUID(uuidString: idString)
        }
        set {
            defaults.set(newValue?.uuidString, forKey: UserDefaultsKey.selectedLocationId)
        }
    }
    
    var selectedPaymentMethod: PaymentMethod {
        get {
            defaults.string(forKey: UserDefaultsKey.selectedPaymentMethod)
                .flatMap { PaymentMethod(rawValue: $0) } ?? .cash
        }
        set { defaults.set(newValue.rawValue, forKey: UserDefaultsKey.selectedPaymentMethod) }
    }
}

// MARK: - Приватные типы

/// Ключи для хранения значений в UserDefaults.
private enum UserDefaultsKey {
    static var baseCurrency = "baseCurrency"
    static var exchangeAdjustment = "exchangeAdjustment"
    static var appAppearance = "appAppearance"
    static var isAddButtonOnLeft = "isAddButtonOnLeft"
    static var selectedLocationId = "selectedLocationId"
    static var selectedPaymentMethod = "selectedPaymentMethod"
}
