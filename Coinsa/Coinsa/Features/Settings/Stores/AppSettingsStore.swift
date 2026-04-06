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
    // MARK: - Stored Properties

    @ObservationIgnored
    private let context: ModelContext

    @ObservationIgnored
    private let defaults = UserDefaults.standard
    
    @ObservationIgnored
    private let settings: AppSettings

    // MARK: - Computed Properties
    
    var baseCurrency: Currency {
        Currency.from(settings.baseCurrencyCode)
    }
    
    var appAppearance: AppAppearance {
        didSet {
            defaults.set(appAppearance.rawValue, forKey: UserDefaultsKey.appAppearance.rawValue)
        }
    }
    
    var isAddButtonOnLeft: Bool {
        didSet {
            defaults.set(isAddButtonOnLeft, forKey: UserDefaultsKey.isAddButtonOnLeft.rawValue)
        }
    }
    
    var selectedCurrentLocation: Location? {
        didSet {
            let idString = selectedCurrentLocation?.id.uuidString
            defaults.set(idString, forKey: UserDefaultsKey.selectedCurrentLocation.rawValue)
        }
    }
    
    // MARK: - Initialization

    init(context: ModelContext) {
        self.context = context

        if let storedSettings = try? context.fetch(FetchDescriptor<AppSettings>()).first {
            settings = storedSettings
        } else {
            let newSettings = AppSettings(baseCurrencyCode: Currency.defaultCurrencyCode)
            context.insert(newSettings)
            settings = newSettings
        }

        appAppearance = defaults.string(forKey: UserDefaultsKey.appAppearance.rawValue)
            .flatMap { AppAppearance(rawValue: $0) } ?? .system
        
        isAddButtonOnLeft = defaults.bool(forKey: UserDefaultsKey.isAddButtonOnLeft.rawValue)
        
        selectedCurrentLocation = loadLocation(context: context)
    }
        
    // MARK: - Private Methods
    
    private func loadLocation(context: ModelContext) -> Location? {
        guard
            let idString = defaults.string(forKey: UserDefaultsKey.selectedCurrentLocation.rawValue),
            let uuid = UUID(uuidString: idString)
        else { return nil }

        let descriptor = FetchDescriptor<Location>(
            predicate: #Predicate { $0.id == uuid }
        )

        return try? context.fetch(descriptor).first
    }
}

// MARK: - Private Types

private enum UserDefaultsKey: String, CaseIterable {
    case appAppearance
    case isAddButtonOnLeft
    case selectedCurrentLocation
}
