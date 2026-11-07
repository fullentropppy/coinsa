//
//  SettingsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

/// Экран настроек приложения.
struct SettingsView: View {
    // MARK: - Окружение

#if DEBUG
    @Environment(\.modelContext) private var context
#endif
    
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
                .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Основной контент

    private var settingsForm: some View {
        Form {
            homeCurrencySection
            exchangeAdjustmentSection
            dataLoadingSection
            appearanceSection
            aboutSection
#if DEBUG
            SettingsDebugSectionView(demoDataService: demoDataService)
#endif
        }
    }
    
    // MARK: - Секции
    
    private var homeCurrencySection: some View {
        Section {
            LabeledPicker(
                title: .settingsHomeCurrency,
                selection: homeCurrencyBinding,
                options: Currency.allCasesSortedByName
            ) { currency in
                currency.makeLabel()
            }
        } footer: {
            Text(.settingsHomeCurrencyHint)
        }
    }

    private var exchangeAdjustmentSection: some View {
        Section {
            LabeledContent(.settingsExchangeAdjustment) {
                PercentInputField.standard(
                    exchangeAdjustmentInputBinding,
                    focusedField: $focusedField,
                    focusID: .exchangeAdjustment
                )
            }
        } footer: {
            Text(.settingsExchangeAdjustmentHint)
        }
    }
    
    private var dataLoadingSection: some View {
        Section {
            Toggle(.settingsFetchExpenseExchangeRateOnline, isOn: fetchExpenseExchangeRateOnline)
                .tint(.accent)
            Toggle(.settingsDetectPlaceOfExpense, isOn: detectPlaceOfExpense)
                .tint(.accent)
        } footer: {
            Text(.settingsExpenseAautofillHint)
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
            
            Toggle(.settingsIsFloatingButtonOnLeft, isOn: isFloatingButtonOnLeftBinding)
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
    
    // MARK: - Биндинги

    private var homeCurrencyBinding: Binding<Currency> {
        Binding(
            get: { settingsStore.homeCurrency },
            set: { settingsStore.homeCurrency = $0 }
        )
    }
    
    private var exchangeAdjustmentInputBinding: Binding<Double> {
        Binding(
            get: { settingsStore.exchangeAdjustment },
            set: { settingsStore.exchangeAdjustment = $0 }
        )
    }
    
    private var fetchExpenseExchangeRateOnline: Binding<Bool> {
        Binding(
            get: { settingsStore.fetchExpenseExchangeRateOnline },
            set: { settingsStore.fetchExpenseExchangeRateOnline = $0 }
        )
    }
    
    private var detectPlaceOfExpense: Binding<Bool> {
        Binding(
            get: { settingsStore.detectPlaceOfExpense },
            set: { settingsStore.detectPlaceOfExpense = $0 }
        )
    }
    
    private var selectedAppAppearance: Binding<AppAppearance> {
        Binding(
            get: { settingsStore.appAppearance },
            set: { settingsStore.appAppearance = $0 }
        )
    }
    
    private var isFloatingButtonOnLeftBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.isFloatingButtonOnLeft },
            set: { settingsStore.isFloatingButtonOnLeft = $0 }
        )
    }
}

// MARK: - Превью

#Preview {
    let container = PreviewBuilder.builder().withTrips(false).buildContainer()
    let store = AppSettingsStore()
    
    SettingsView()
        .modelContainer(container)
        .environment(store)
}
