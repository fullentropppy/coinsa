//
//  AppSettingsStore.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class AppSettingsStore {
    // MARK: - Хранимые свойства

    @ObservationIgnored
    private let context: ModelContext

    @ObservationIgnored
    private let defaults = UserDefaults.standard
    
    @ObservationIgnored
    private let settings: AppSettings

    // MARK: - Вычисляемые свойства
    
    var baseCurrency: Currency {
        Currency.from(settings.baseCurrencyCode)
    }
    
    var appAppearance: AppAppearance {
        didSet {
            defaults.set(appAppearance.rawValue, forKey: UserDefaultsKey.appAppearance)
        }
    }
    
    var isAddButtonOnLeft: Bool {
        didSet {
            defaults.set(isAddButtonOnLeft, forKey: UserDefaultsKey.isAddButtonOnLeft)
        }
    }
    
    var selectedCurrentLocation: Location? {
        didSet {
            let idString = selectedCurrentLocation?.id.uuidString
            defaults.set(idString, forKey: UserDefaultsKey.selectedCurrentLocation)
        }
    }
    
    // MARK: - Инициализация

    init(context: ModelContext) {
        self.context = context

        if let storedSettings = try? context.fetch(FetchDescriptor<AppSettings>()).first {
            settings = storedSettings
        } else {
            let newSettings = AppSettings(baseCurrencyCode: Currency.defaultCurrencyCode)
            context.insert(newSettings)
            settings = newSettings
        }

        appAppearance = defaults.string(forKey: UserDefaultsKey.appAppearance)
            .flatMap { AppAppearance(rawValue: $0) } ?? .system
        
        isAddButtonOnLeft = defaults.bool(forKey: UserDefaultsKey.isAddButtonOnLeft)
        
        selectedCurrentLocation = loadLocation(context: context)
    }
        
    // MARK: - Приватные методы
    
    private func loadLocation(context: ModelContext) -> Location? {
        guard
            let idString = defaults.string(forKey: UserDefaultsKey.selectedCurrentLocation),
            let uuid = UUID(uuidString: idString)
        else { return nil }

        let descriptor = FetchDescriptor<Location>(
            predicate: #Predicate { $0.id == uuid }
        )

        return try? context.fetch(descriptor).first
    }
}

// MARK: - Приватные типы

private enum UserDefaultsKey {
    static var appAppearance = "appAppearance"
    static var isAddButtonOnLeft = "isAddButtonOnLeft"
    static var selectedCurrentLocation = "selectedCurrentLocation"
}
