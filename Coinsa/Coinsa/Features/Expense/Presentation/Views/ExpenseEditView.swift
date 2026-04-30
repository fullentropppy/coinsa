//
//  ExpenseEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseEditView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние
    
    @State private var viewModel: ExpenseEditViewModel
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var inputCurrency: InputCurrency
    @State private var isShowingDiscardAlert = false
    
    @FocusState private var focusedField: NumericEditField?
    
    // MARK: - Зависимости
    
    private let onDelete: (() -> Void)?

    // MARK: - Инфраструктура
    
    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }
    
    // MARK: - Инициализация
    
    init(
        forCreateWith location: Location,
        preselectedCategory: ExpenseCategory? = nil,
        preselectedPaymentMethod: PaymentMethod? = nil
    ) {
        let viewModel = ExpenseEditViewModel(
            forCreateWith: location,
            preselectedCategory: preselectedCategory,
            preselectedPaymentMethod: preselectedPaymentMethod
        )
        self.init(initialViewModel: viewModel)
    }
    
    init(forEdit expense: Expense, onDelete: (() -> Void)? = nil) {
        let viewModel = ExpenseEditViewModel(forEdit: expense)
        self.init(initialViewModel: viewModel, onDelete: onDelete)
    }
    
    private init(initialViewModel: ExpenseEditViewModel, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: initialViewModel)
        _inputCurrency = State(
            initialValue: initialViewModel.baseCurrency == initialViewModel.localCurrency ? .base : .local
        )
        self.onDelete = onDelete
    }
    
    // MARK: - Тело View
    
    var body: some View {
        NavigationStack {
            expenseEditForm
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.location.screenContextSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(true)
                .scrollDismissesKeyboard(.interactively)
                .notificationAlert(
                    isPresented: rateErrorBinding,
                    title: .exchangeRateLoadingErrorTitle,
                    message: .exchangeRateLoadingErrorMessage(
                        errorDescription: viewModel.rateLoadingError?.errorDescription
                        ?? String(localized: .errorUnknown)
                    ),
                    isError: true
                )
                .discardConfirmationAlert(
                    isPresented: $isShowingDiscardAlert,
                    onConfirm: { dismiss() }
                )
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    title: .expenseDeleteTitle,
                    message: .expenseDeleteMessage,
                    onConfirm: {
                        confirmDelete()
                        dismiss()
                    },
                    onCancel: { cancelDelete() }
                )
                .task {
                    viewModel.loadInitialRateIfNeeded()
                }
        }
    }

    // MARK: Основной контент
    
    private var expenseEditForm: some View {
        Form {
            dateSection
            specificationsSection
            amountSection
            commentSection
            actionsSection
        }
    }
    
    // MARK: - Секции
    
    private var dateSection: some View {
        Section {
            DatePicker(
                .expenseDate,
                selection: $viewModel.date,
                in: viewModel.location.range
            )
        }
    }
    
    private var specificationsSection: some View {
        Section {
            LabeledPicker(
                title: .expenseCategory,
                selection: categoryBinding,
                options: ExpenseCategory.allCases
            ) { category in
                category.makeLabel()
            }
            LabeledPicker(
                title: .expensePaymentMethod,
                selection: paymentMethodBinding,
                options: PaymentMethod.allCases
            ) { method in
                method.makeLabel()
            }
        }
    }
    
    private var amountSection: some View {
        Section {
            LabeledContent(.expenseAmount) {
                HStack {
                    NumericInputField.standard(
                        amountInputBinding,
                        focusedField: $focusedField,
                        focusId: .amount,
                        fractionDigits: 2
                    )
                    CurrencyCodeText.standard(viewModel.currency(for: inputCurrency))
                    if !viewModel.isHomeLocation {
                        InputCurrencySwitchButton(action: switchInputCurrency)
                    }
                }
            }
            
            if !viewModel.isHomeLocation {
                LabeledContent(.expenseExchangeRate(localCurrencyCode: viewModel.localCurrency.code)) {
                    ExchangeRateInputField.standard(
                        rateInputBinding,
                        currency: viewModel.baseCurrency,
                        isLoading: viewModel.isRateLoading,
                        focusedField: $focusedField,
                        focusId: .exchangeRate,
                        onRefresh: { viewModel.requestRateRefresh(for: inputCurrency) }
                    )
                }
                
                if viewModel.useExchangeAdjustment {
                    LabeledContent(.locationExchangeAdjustment) {
                        PercentInputField.standard(
                            exchangeAdjustmentInputBinding,
                            focusedField: $focusedField,
                            focusId: .exchangeAdjustment
                        )
                    }
                }
            }
        } footer: {
            if let adjustedExchangeRateDescription = viewModel.adjustedRateDescription {
                Text(adjustedExchangeRateDescription)
            }
        }
    }
    
    private var commentSection: some View {
        Section {
            TextField(.expenseComment, text: $viewModel.comment)
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEdit {
            Section {
                Button(.expenseDelete, role: .destructive) {
                    requestDelete()
                }
            }
        }
    }

    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            ToolbarButton.close {
                handleClose()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.ok {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
        }
    }

    // MARK: - Биндинги
    
    private var categoryBinding: Binding<ExpenseCategory> {
        Binding(
            get: { viewModel.category },
            set: { viewModel.category = $0 }
        )
    }

    private var paymentMethodBinding: Binding<PaymentMethod> {
        Binding(
            get: { viewModel.paymentMethod },
            set: { newMethod in
                viewModel.updatePaymentMethod(newMethod, currentInput: inputCurrency)
                settingsStore.selectedPaymentMethod = newMethod
            }
        )
    }
    
    private var amountInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.amount(for: inputCurrency) },
            set: { newValue in
                viewModel.updateAmount(newValue, for: inputCurrency)
            }
        )
    }
    
    private var rateInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.rateLocalToBase },
            set: { newValue in
                viewModel.updateRate(newValue, currentInput: inputCurrency)
            }
        )
    }
    
    private var rateErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.rateLoadingError != nil },
            set: { shouldShow in
                if !shouldShow {
                    viewModel.rateLoadingError = nil
                }
            }
        )
    }
    
    private var exchangeAdjustmentInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.exchangeAdjustment },
            set: { newValue in
                viewModel.updateExchangeAdjustment(newValue, currentInput: inputCurrency)
            }
        )
    }
    
    // MARK: - Действия
    
    private func switchInputCurrency() {
        switch inputCurrency {
        case .base: inputCurrency = .local
        case .local: inputCurrency = .base
        }
    }
    
    private func handleClose() {
        if viewModel.hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }

    private func requestDelete() {
        if let expense = viewModel.expense {
            deletionHandler.request(for: [expense])
        }
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
        onDelete?()
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Превью

private extension ExpenseEditView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withNewExpense: Bool = false
    ) -> some View { 
        let builder = PreviewBuilder.builder().withBudgets(false)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore()
        let location = builder.fetchLocation(from: container)
       
        return Group {
            if withNewExpense {
                return ExpenseEditView(forCreateWith: location)
            } else {
                let expense = builder.fetchExpense(from: container)
                return ExpenseEditView(forEdit: expense)
            }
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Edit. Light - RU") {
    ExpenseEditView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Edit. Dark - EN") {
    ExpenseEditView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("Create. Light - RU") {
    ExpenseEditView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withNewExpense: true)
}

#Preview("Create. Dark - EN") {
    ExpenseEditView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withNewExpense: true)
}
