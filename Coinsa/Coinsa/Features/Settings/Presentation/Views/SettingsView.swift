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
                .keyboardInputBar(isPresented: focusedField == .exchangeAdjustment) {
                    focusedField = nil
                }
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
            CurrencyPicker(
                title: .settingsHomeCurrency,
                selection: homeCurrencyBinding
            ) { currency in
                CurrencyCodeText.standard(currency)
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
            Toggle(.settingsDetectExpensePlace, isOn: detectPlaceOfExpense)
                .tint(.accent)
        } footer: {
            Text(.settingsExpenseAutofillHint)
        }
    }
    
    private var todayBudgetSection: some View {
        Section {
            Toggle(.settingsTodayBudgetAutoSwitch, isOn: showsLocationBudgetOnOverspendBinding)
                .tint(.accent)

            if settingsStore.showsLocationBudgetOnOverspend {
                VStack {
                    LabeledContent(.settingsTodayBudgetOverspendThreshold) {
                        HStack {
                            Text((settingsStore.todayBudgetOverspendThreshold).numberFormat(fractionLength: 0))
                                .foregroundStyle(.primary)
                            Image(systemName: "percent")
                                .fontWeight(.semibold)
                                .imageScale(.small)
                                .foregroundStyle(.secondary)
                                .frame(width: ViewLayout.Label.inputAccessoryWidth)
                        }
                    }
                    Slider(value: todayBudgetOverspendThresholdBinding, in: 0...100, step: 5) {
                        Text(.settingsTodayBudgetOverspendThreshold)
                    }
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
                appAppearance.makeLabel()
            }
            
            Toggle(.settingsFloatingButtonsOnLeft, isOn: isFloatingButtonOnLeftBinding)
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
    @Previewable @State var preview = PreviewEnvironment()
    
    SettingsView()
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}
