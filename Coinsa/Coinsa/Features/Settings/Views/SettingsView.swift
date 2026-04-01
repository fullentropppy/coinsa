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
            settingsForm
                .navigationTitle(.settingsNavigationTitle)
                .navigationBarTitleDisplayMode(.large)
                .safeAreaInset(edge: .bottom) {
                    appInfoFooter
                }
        }
    }

    // MARK: - Content

    private var settingsForm: some View {
        Form {
            baseCurrencySection
            appearanceSection
        }
    }
    
    // MARK: - Sections
    
    private var baseCurrencySection: some View {
        Section {
            LabeledContent(.settingsBaseCurrency) {
                Text(appSettingsStore.baseCurrency.localized)
            }
        } footer: {
            Text(.settingsBaseCurrencyHint)
                .multilineTextAlignment(.leading)
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker(.settingsAppAppearance, selection: selectedAppAppearance) {
                ForEach(AppAppearance.allCases) { theme in
                    Text(theme.localized)
                        .tag(theme)
                }
            }
            .pickerStyle(.navigationLink)
            
            Toggle(.settingsIsAddButtonOnLeft, isOn: isAddButtonOnLeftBinding)
                .tint(.accent)
        }
    }
    
    // MARK: - Components
    
    private var appInfoFooter: some View {
        VStack(alignment: .center) {
            Text(AppInfo.appName)
            Text(.appVersion(AppInfo.version, AppInfo.build))
            HStack {
                Text(AppInfo.copyrightYears)
                Text(.appAuthor)
            }
        }
        .font(.footnote)
        .foregroundStyle(.gray)
        .padding(.bottom, 24)
    }

    // MARK: - Bindings

    private var selectedAppAppearance: Binding<AppAppearance> {
        Binding(
            get: { appSettingsStore.appAppearance },
            set: { appSettingsStore.appAppearance = $0 }
        )
    }
    
    private var isAddButtonOnLeftBinding: Binding<Bool> {
        Binding(
            get: { appSettingsStore.isAddButtonOnLeft },
            set: { appSettingsStore.isAddButtonOnLeft = $0 }
        )
    }
}

// MARK: - Previews

private extension SettingsView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let container = PreviewBuilder.builder().withTrips(false).buildContainer()
        let store = AppSettingsStore(context: container.mainContext)
        
        return SettingsView()
            .modelContainer(container)
            .environment(store)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    SettingsView.makePreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    SettingsView.makePreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
