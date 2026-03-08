//
//  SettingsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // MARK: - Stored Properties

    @Environment(AppSettingsStore.self) private var settingsStore

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                baseCurrencySection
                themeSection
            }
            .navigationTitle("settings.navigationTitle")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Components

    private var baseCurrencySection: some View {
        Section {
            Picker("settings.baseCurrency.title", selection: baseCurrencyOptionBinding) {
                ForEach(CurrencyOption.allCasesSortedByName) { option in
                    Text(option.localizedDisplayName)
                        .tag(option)
                }
            }
            .pickerStyle(.navigationLink)
        } footer: {
            Text("settings.baseCurrency.footer")
        }
    }

    private var themeSection: some View {
        Section {
            Picker("settings.theme.title", selection: themeBinding) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.titleKey)
                        .tag(theme)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Bindings

    private var baseCurrencyOptionBinding: Binding<CurrencyOption> {
        Binding(
            get: { CurrencyOption.from(code: settingsStore.baseCurrencyCode) },
            set: { settingsStore.baseCurrencyCode = $0.code }
        )
    }

    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: { settingsStore.selectedTheme },
            set: { settingsStore.selectedTheme = $0 }
        )
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    let container = PreviewBuilder.builder().buildContainer()
    let store = AppSettingsStore(context: container.mainContext)
    store.baseCurrencyCode = PreviewCurrency.baseCurrencyCode

    return SettingsView()
        .modelContainer(container)
        .environment(store)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}
