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
    
    var isAddButtonOnLeft: Bool {
        didSet {
            defaults.set(isAddButtonOnLeft, forKey: UserDefaultsKey.isAddButtonOnLeft.rawValue)
        }
    }
    
    var appAppearance: AppAppearance {
        didSet {
            defaults.set(appAppearance.rawValue, forKey: UserDefaultsKey.appAppearance.rawValue)
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

        isAddButtonOnLeft = defaults.bool(forKey: UserDefaultsKey.isAddButtonOnLeft.rawValue)
        appAppearance = defaults.string(forKey: UserDefaultsKey.appAppearance.rawValue)
            .flatMap { AppAppearance(rawValue: $0) } ?? .system
    }
}

// MARK: - Private Types

private enum UserDefaultsKey: String, CaseIterable {
    case isAddButtonOnLeft
    case appAppearance
}
