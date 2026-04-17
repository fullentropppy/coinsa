//
//  UserDefaultsSettingsManager.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import Foundation

final class UserDefaultsSettingsManager {
    // MARK: - Зависимости
    
    private let defaults = UserDefaults.standard
    
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

private enum UserDefaultsKey {
    static var appAppearance = "appAppearance"
    static var isAddButtonOnLeft = "isAddButtonOnLeft"
    static var selectedLocationId = "selectedLocationId"
    static var selectedPaymentMethod = "selectedPaymentMethod"
}
