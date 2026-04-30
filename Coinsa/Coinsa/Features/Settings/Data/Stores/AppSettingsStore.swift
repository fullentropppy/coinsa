//
//  AppSettingsStore.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class AppSettingsStore {
    // MARK: - Зависимости
    
    private let userDefaultsManager: UserDefaultsSettingsManager
    
    // MARK: - Параметры учета
    
    var baseCurrency: Currency {
        didSet { userDefaultsManager.baseCurrency = baseCurrency }
    }
    
    var exchangeAdjustment: Double {
        didSet { userDefaultsManager.exchangeAdjustment = exchangeAdjustment }
    }
    
    // MARK: - Оформление
    
    var appAppearance: AppAppearance {
        didSet { userDefaultsManager.appAppearance = appAppearance }
    }
    
    var isAddButtonOnLeft: Bool {
        didSet { userDefaultsManager.isAddButtonOnLeft = isAddButtonOnLeft }
    }
    
    // MARK: - Сохраненный выбор
    
    var selectedLocationID: UUID? {
        didSet { userDefaultsManager.selectedLocationID = selectedLocationID }
    }
    
    var selectedPaymentMethod: PaymentMethod {
        didSet { userDefaultsManager.selectedPaymentMethod = selectedPaymentMethod }
    }
    
    // MARK: - Инициализация
    
    init() {
        self.userDefaultsManager = UserDefaultsSettingsManager()
        
        self.baseCurrency = userDefaultsManager.baseCurrency
        self.exchangeAdjustment = userDefaultsManager.exchangeAdjustment
        self.appAppearance = userDefaultsManager.appAppearance
        self.isAddButtonOnLeft = userDefaultsManager.isAddButtonOnLeft
        self.selectedLocationID = userDefaultsManager.selectedLocationID
        self.selectedPaymentMethod = userDefaultsManager.selectedPaymentMethod
    }
}
