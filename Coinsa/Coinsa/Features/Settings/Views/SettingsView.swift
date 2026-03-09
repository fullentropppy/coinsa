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
        }
    }

    // MARK: - Components

    private var baseCurrencySection: some View {
        Section {
            LabeledContent("settings.baseCurrency.title") {
                Text(CurrencyOption.baseOption.localizedDisplayName)
            }
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

    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: { settingsStore.selectedTheme },
            set: { settingsStore.selectedTheme = $0 }
        )
    }
}

// MARK: - Previews

private extension SettingsView {
    private struct PreviewData {
        let container: ModelContainer
        let store: AppSettingsStore
        
        init() {
            self.container = PreviewBuilder.builder().buildContainer()
            self.store = AppSettingsStore(context: container.mainContext)
        }
    }
    
    static func preview(locale: String, colorScheme: ColorScheme) -> some View {
        let data = PreviewData()
        
        return SettingsView()
            .modelContainer(data.container)
            .environment(data.store)
            .environment(\.locale, Locale(identifier: locale))
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    SettingsView.preview(locale: "ru", colorScheme: .light)
}

#Preview("Dark - EN") {
    SettingsView.preview(locale: "en", colorScheme: .dark)
}
