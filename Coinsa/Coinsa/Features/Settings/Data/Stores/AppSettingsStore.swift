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
    
    private let swiftDataManager: SwiftDataSettingsManager
    private let userDefaultsManager: UserDefaultsSettingsManager
    
    // MARK: - Параметры учета
    
    var baseCurrency: Currency {
        didSet { swiftDataManager.baseCurrency = baseCurrency }
    }
    
    var exchangeAdjustment: Double {
        didSet { swiftDataManager.exchangeAdjustment = exchangeAdjustment }
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
    
    init(context: ModelContext) {
        self.swiftDataManager = SwiftDataSettingsManager(context: context)
        self.userDefaultsManager = UserDefaultsSettingsManager()
        
        self.baseCurrency = swiftDataManager.baseCurrency
        self.exchangeAdjustment = swiftDataManager.exchangeAdjustment
        self.appAppearance = userDefaultsManager.appAppearance
        self.isAddButtonOnLeft = userDefaultsManager.isAddButtonOnLeft
        self.selectedLocationID = userDefaultsManager.selectedLocationID
        self.selectedPaymentMethod = userDefaultsManager.selectedPaymentMethod
    }
}
