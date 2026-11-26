//
//  TripFormView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI
import SwiftData

/// Форма поездки с секциями и привязками к общему черновику и фокусу редактора.
struct TripFormView: View {
    // MARK: - Свойства

    @Bindable private var viewModel: TripEditViewModel
    private let isNameFocused: FocusState<Bool>.Binding
    private let focusedField: FocusState<NumericEditField?>.Binding
    private let onDelete: () -> Void

    // MARK: - Инициализация

    /// Создает секции, используя черновик и управление фокусом родительского редактора.
    /// - Parameters:
    ///   - viewModel: Общий черновик поездки.
    ///   - isNameFocused: Фокус названия, принадлежащий контейнеру.
    ///   - focusedField: Фокус числового поля бюджета, принадлежащий контейнеру.
    ///   - onDelete: Запрос подтверждения удаления.
    init(
        viewModel: TripEditViewModel,
        isNameFocused: FocusState<Bool>.Binding,
        focusedField: FocusState<NumericEditField?>.Binding,
        onDelete: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.isNameFocused = isNameFocused
        self.focusedField = focusedField
        self.onDelete = onDelete
    }

    // MARK: - Тело View

    var body: some View {
        Form {
            titleSection
            rangeSection
            currencySection
            budgetSection
            actionsSection
        }
    }

    // MARK: - Секции
    
    private var titleSection: some View {
        Section {
            TextField(.tripNamePlaceholder, text: $viewModel.name)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
                .focused(isNameFocused)
                .keyboardClearAction(text: $viewModel.name)
        }
        .listRowBackground(Color.clear)
    }
    
    private var rangeSection: some View {
        Section {
            DatePicker(
                selection: Binding(
                    get: { viewModel.startDate },
                    set: { viewModel.startDate = $0 }
                ),
                displayedComponents: .date
            ) {
                HStack {
                    AppIcon(AppSymbols.calendarBadgePlus, style: .formLabel)
                    Text(.tripStartDate)
                }
            }
            .environment(\.timeZone, .utc)
            DatePicker(
                selection: Binding(
                    get: { viewModel.endDate },
                    set: { viewModel.endDate = $0 }
                ),
                in: viewModel.startDate...,
                displayedComponents: .date
            ) {
                HStack {
                    AppIcon(AppSymbols.calendarBadgeCheckmark, style: .formLabel)
                    Text(.tripEndDate)
                }
            }
            .environment(\.timeZone, .utc)
        } footer: {
            Text(.totalDays(totalDays: viewModel.totalDays))
        }
    }
    
    private var currencySection: some View {
        Section {
            CurrencyPicker(
                title: .tripHomeCurrency,
                selection: homeCurrencyBinding,
                sections: Currency.pickerSections(homeCurrency: viewModel.homeCurrency),
                isDisabled: viewModel.isHomeCurrencyLocked
            ) { currency in
                CurrencyCodeText.standard(currency)
            }
        } footer: {
            Text(.tripHomeCurrencyHint)
        }
    }
    
    private var budgetSection: some View {
        Section {
            LabeledContent(.tripGeneralExpensesBudget) {
                HStack {
                    NumericInputField(
                        $viewModel.generalExpensesBudget,
                        focusedField: focusedField,
                        focusID: .budget,
                        fractionDigits: 2,
                        font: .body.monospacedDigit(),
                        textAlignment: .trailing
                    )
                    CurrencyCodeText.standard(viewModel.homeCurrency)
                }
            }
        } footer: {
            Text(.tripGeneralExpensesBudgetHint)
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEditing {
            Section {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    HStack {
                        Image(systemName: AppSymbols.trash)
                        Text(.tripDelete)
                    }
                }
            }
        }
    }
    
    // MARK: - Биндинги

    private var homeCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.homeCurrency },
            set: { viewModel.homeCurrency = $0 }
        )
    }

}

// MARK: - Превью

private struct TripFormPreview: View {
    let preview: TripPreviewData

    @FocusState private var isNameFocused: Bool
    @FocusState private var focusedField: NumericEditField?

    var body: some View {
        if let viewModel = preview.viewModel {
            NavigationStack {
                TripFormView(
                    viewModel: viewModel,
                    isNameFocused: $isNameFocused,
                    focusedField: $focusedField,
                    onDelete: {}
                )
                .keyboardInputBar(isPresented: isNameFocused || focusedField != nil) {
                    isNameFocused = false
                    focusedField = nil
                }
            }
            .modelContainer(preview.container)
            .environment(preview.settingsStore)
        }
    }
}

#Preview("Editing") {
    @Previewable @State var preview = TripPreviewData()

    TripFormPreview(preview: preview)
}

#Preview("Creating") {
    @Previewable @State var preview = TripPreviewData(isEditing: false)

    TripFormPreview(preview: preview)
}
