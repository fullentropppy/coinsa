//
//  SettingsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    
    // MARK: - Состояние
    
    @FocusState private var focusedField: NumericEditField?
    
    // MARK: - Вычисляемые свойства
    
#if DEBUG
    private var demoDataService: DemoDataService {
        DemoDataService(context: context)
    }
#endif
    
    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            settingsForm
                .navigationTitle(.settingsNavigationTitle)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    toolbarContent
                }
                .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Основной контент

    private var settingsForm: some View {
        Form {
            baseCurrencySection
            exchangeAdjustmentSection
            appearanceSection
            aboutSection
#if DEBUG
            SettingsDebugSectionView(demoDataService: demoDataService)
#endif
        }
    }
    
    // MARK: - Секции
    
    private var baseCurrencySection: some View {
        Section {
            LabeledContent(.settingsBaseCurrency) {
                settingsStore.baseCurrency.makeLabel()
            }
        } footer: {
            Text(.settingsBaseCurrencyHint)
        }
    }

    private var exchangeAdjustmentSection: some View {
        Section {
            LabeledContent(.settingsExchangeAdjustment) {
                PercentInputField.standard(
                    exchangeAdjustmentInputBinding,
                    focusedField: $focusedField,
                    focusId: .exchangeAdjustment
                )
            }
        } footer: {
            Text(.settingsExchangeAdjustmentHint)
        }
    }
    
    private var appearanceSection: some View {
        Section {
            Picker(.settingsAppAppearance, selection: selectedAppAppearance) {
                ForEach(AppAppearance.allCases) { theme in
                    Text(theme.localizedResource)
                        .tag(theme)
                }
            }
            .pickerStyle(.navigationLink)
            
            Toggle(.settingsIsAddButtonOnLeft, isOn: isAddButtonOnLeftBinding)
                .tint(.accent)
        }
    }
    
    private var aboutSection: some View {
        Section {
            NavigationLink(.settingsAbout) {
                AboutView()
            }
        }
    }
    
    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            if focusedField != nil {
                Spacer()
                ToolbarButton.ok {
                    focusedField = nil
                }
            }
        }
    }
    
    // MARK: - Биндинги

    private var exchangeAdjustmentInputBinding: Binding<Double> {
        Binding(
            get: { settingsStore.exchangeAdjustment },
            set: { settingsStore.exchangeAdjustment = $0 }
        )
    }
    
    private var selectedAppAppearance: Binding<AppAppearance> {
        Binding(
            get: { settingsStore.appAppearance },
            set: { settingsStore.appAppearance = $0 }
        )
    }
    
    private var isAddButtonOnLeftBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.isAddButtonOnLeft },
            set: { settingsStore.isAddButtonOnLeft = $0 }
        )
    }
}

// MARK: - Превью

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
    SettingsView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    SettingsView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
