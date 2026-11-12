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
            todayBudgetSection
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
            } currentValueLabel: { currency in
                CurrencyCodeText(currency)
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
    
    private var todayBudgetSection: some View {
        Section {
            Toggle(.settingsTodayBudgetAutoSwitch, isOn: showsLocationBudgetOnOverspendBinding)
                .tint(.accent)

            if settingsStore.showsLocationBudgetOnOverspend {
                VStack {
                    LabeledContent(.settingsTodayBudgetOverspendThreshold) {
                        Text((settingsStore.todayBudgetOverspendThreshold / 100).percentFormat(fractionLength: 0))
                    }
                    Slider(value: todayBudgetOverspendThresholdBinding, in: 0...100, step: 5) {
                        Text(.settingsTodayBudgetOverspendThreshold)
                    } minimumValueLabel: {
                        Text(0.0.percentFormat(fractionLength: 0))
                    } maximumValueLabel: {
                        Text(1.0.percentFormat(fractionLength: 0))
                    }
                    .accessibilityValue(
                        (settingsStore.todayBudgetOverspendThreshold / 100).percentFormat(fractionLength: 0)
                    )
                }
            }
        } footer: {
            Text(.settingsTodayBudgetAutoSwitchHint)
        }
    }

    private var appearanceSection: some View {
        Section {
            LabeledPicker(
                title: .settingsAppAppearance,
                selection: selectedAppAppearance,
                options: AppAppearance.allCases
            ) { appAppearance in
                Text(appAppearance.localizedResource)
            }
            
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
    
    private var showsLocationBudgetOnOverspendBinding: Binding<Bool> {
        Binding(
            get: { settingsStore.showsLocationBudgetOnOverspend },
            set: { settingsStore.showsLocationBudgetOnOverspend = $0 }
        )
    }

    private var todayBudgetOverspendThresholdBinding: Binding<Double> {
        Binding(
            get: { settingsStore.todayBudgetOverspendThreshold },
            set: { settingsStore.todayBudgetOverspendThreshold = $0 }
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
