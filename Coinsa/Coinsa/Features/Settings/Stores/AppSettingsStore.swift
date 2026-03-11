//
//  AppSettingsStore.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class AppSettingsStore {
    // MARK: - Stored Properties

    @ObservationIgnored
    private let context: ModelContext

    @ObservationIgnored
    private let settings: AppSettings

    @ObservationIgnored
    private let themeKey = "appTheme"

    @ObservationIgnored
    private let defaults = UserDefaults.standard

    // MARK: - Computed Properties
    
    private var baseCurrencyCode: String {
        settings.baseCurrencyCode
    }

    var baseCurrencyOption: CurrencyOption {
        CurrencyOption.from(code: baseCurrencyCode)
    }
    
    var selectedTheme: AppTheme {
        didSet {
            defaults.set(selectedTheme.rawValue, forKey: themeKey)
        }
    }

    // MARK: - Initialization

    init(context: ModelContext) {
        self.context = context

        if let storedSettings = try? context.fetch(FetchDescriptor<AppSettings>()).first {
            settings = storedSettings
        } else {
            let newSettings = AppSettings(baseCurrencyCode: CurrencyOption.defaultCurrencyCode)
            context.insert(newSettings)
            settings = newSettings
        }

        let rawTheme = defaults.string(forKey: themeKey) ?? AppTheme.system.rawValue
        selectedTheme = AppTheme(rawValue: rawTheme) ?? .system
    }
}
