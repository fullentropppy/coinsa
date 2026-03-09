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

    let baseCurrencyCode: String

    var selectedTheme: AppTheme {
        didSet {
            defaults.set(selectedTheme.rawValue, forKey: themeKey)
        }
    }

    var colorScheme: ColorScheme? {
        selectedTheme.colorScheme
    }

    // MARK: - Initialization

    init(context: ModelContext) {
        self.context = context

        if let stored = try? context.fetch(FetchDescriptor<AppSettings>()).first {
            settings = stored
        } else {
            let newSettings = AppSettings(baseCurrencyCode: CurrencyOption.baseCurrencyCode)
            context.insert(newSettings)
            settings = newSettings
        }

        baseCurrencyCode = CurrencyOption.baseCurrencyCode
        settings.baseCurrencyCode = baseCurrencyCode

        let rawTheme = defaults.string(forKey: themeKey) ?? AppTheme.system.rawValue
        selectedTheme = AppTheme(rawValue: rawTheme) ?? .system
    }
}
