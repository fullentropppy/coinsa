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
            content
            .navigationTitle("settings.navigationTitle")
            .safeAreaInset(edge: .bottom) {
                appInfo
            }
        }
    }

    // MARK: - Content

    private var content: some View {
        Form {
            baseCurrencySection
            appearanceSection
        }
    }
    
    // MARK: - Sections
    
    private var baseCurrencySection: some View {
        Section {
            LabeledContent("settings.baseCurrency") {
                Text(appSettingsStore.baseCurrency.localizedKey)
            }
        } footer: {
            Text("settings.baseCurrency.hint")
                .multilineTextAlignment(.leading)
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("settings.theme", selection: themeBinding) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.localizedKey)
                        .tag(theme)
                }
            }
            .pickerStyle(.navigationLink)
            
            Toggle("settings.primaryAddButtonPosition", isOn: primaryAddButtonPositionBinding)
                .tint(.accent)
        }
    }
    
    // MARK: - Components
    
    private var appInfo: some View {
        VStack(alignment: .center) {
            Text(AppInfo.appName)
            Text(
                String(
                    format: NSLocalizedString("app.version", comment: ""),
                    AppInfo.version,
                    AppInfo.build
                )
            )
            HStack {
                Text(AppInfo.copyrightYears)
                Text(AppInfo.authorName)
            }
        }
        .font(.footnote)
        .foregroundStyle(.gray)
        .padding(.bottom, 24)
    }

    // MARK: - Bindings

    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: { appSettingsStore.selectedTheme },
            set: { appSettingsStore.selectedTheme = $0 }
        )
    }
    
    private var primaryAddButtonPositionBinding: Binding<Bool> {
        Binding(
            get: { appSettingsStore.isPrimaryAddButtonOnLeft },
            set: { appSettingsStore.isPrimaryAddButtonOnLeft = $0 }
        )
    }
}

// MARK: - Previews

private extension SettingsView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
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
    SettingsView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    SettingsView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
