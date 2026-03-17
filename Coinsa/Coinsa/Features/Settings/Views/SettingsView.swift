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

    @Environment(AppSettingsStore.self) private var appSettingsStore

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
                Text(appSettingsStore.baseCurrency.localizedKey)
            }
        } footer: {
            Text("settings.baseCurrency.footer")
        }
    }

    private var themeSection: some View {
        Section {
            Picker("settings.theme.title", selection: themeBinding) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.localizedKey)
                        .tag(theme)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Bindings

    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: { appSettingsStore.selectedTheme },
            set: { appSettingsStore.selectedTheme = $0 }
        )
    }
}

// MARK: - Previews

private extension SettingsView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let container = PreviewBuilder.builder().buildContainer()
        let store = AppSettingsStore(context: container.mainContext)
        
        return SettingsView()
            .modelContainer(container)
            .environment(store)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    SettingsView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    SettingsView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
