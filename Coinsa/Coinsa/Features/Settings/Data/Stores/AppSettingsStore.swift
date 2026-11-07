//
//  AppSettingsStore.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import SwiftData

/// Хранилище настроек приложения.
@MainActor
@Observable
final class AppSettingsStore {
    // MARK: - Зависимости
    
    private let userDefaultsManager: UserDefaultsSettingsManager
    
    // MARK: - Параметры учета
    
    var homeCurrency: Currency {
        didSet { userDefaultsManager.homeCurrency = homeCurrency }
    }
    
    var exchangeAdjustment: Double {
        didSet { userDefaultsManager.exchangeAdjustment = exchangeAdjustment }
    }
    
    // MARK: - Автозагрузка/определение данных
    
    var fetchExpenseExchangeRateOnline: Bool {
        didSet { userDefaultsManager.fetchExpenseExchangeRateOnline = fetchExpenseExchangeRateOnline }
    }
    
    var detectPlaceOfExpense: Bool {
        didSet { userDefaultsManager.detectPlaceOfExpense = detectPlaceOfExpense }
    }
    
    // MARK: - Оформление
    
    var appAppearance: AppAppearance {
        didSet { userDefaultsManager.appAppearance = appAppearance }
    }
    
    var isFloatingButtonOnLeft: Bool {
        didSet { userDefaultsManager.isFloatingButtonOnLeft = isFloatingButtonOnLeft }
    }
    
    // MARK: - Сохраненный выбор
    
    var selectedLocationID: UUID? {
        didSet { userDefaultsManager.selectedLocationID = selectedLocationID }
    }
    
    var selectedPaymentMethod: PaymentMethod {
        didSet { userDefaultsManager.selectedPaymentMethod = selectedPaymentMethod }
    }
    
    // MARK: - Инициализация
    
    /// Создает хранилище настроек, загружая значения из UserDefaults.
    init() {
        self.userDefaultsManager = UserDefaultsSettingsManager()
        self.homeCurrency = userDefaultsManager.homeCurrency
        self.exchangeAdjustment = userDefaultsManager.exchangeAdjustment
        self.fetchExpenseExchangeRateOnline = userDefaultsManager.fetchExpenseExchangeRateOnline
        self.detectPlaceOfExpense = userDefaultsManager.detectPlaceOfExpense
        self.appAppearance = userDefaultsManager.appAppearance
        self.isFloatingButtonOnLeft = userDefaultsManager.isFloatingButtonOnLeft
        self.selectedLocationID = userDefaultsManager.selectedLocationID
        self.selectedPaymentMethod = userDefaultsManager.selectedPaymentMethod
    }
}
