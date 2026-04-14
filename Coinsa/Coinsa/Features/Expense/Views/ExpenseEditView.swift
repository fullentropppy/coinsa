//
//  ExpenseEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseEditView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    @State private var viewModel: ExpenseEditViewModel
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var inputCurrency: InputCurrency
    @State private var isShowingDiscardAlert = false
    
    @FocusState private var focusedField: NumericEditField?
    
    // MARK: - Dependencies
    private let onDelete: (() -> Void)?

    // MARK: - Infrastructure
    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }
    
    // MARK: - Initializers
    init(
        expense: Expense,
        baseCurrency: Currency,
        onDelete: (() -> Void)? = nil
    ) {
        self.init(
            expense: expense,
            location: expense.location,
            baseCurrency: baseCurrency,
            preselectedCategory: nil,
            onDelete: onDelete
        )
    }

    
    init(
        location: Location,
        baseCurrency: Currency,
        preselectedCategory: ExpenseCategory? = nil
    ) {
        self.init(
            expense: nil,
            location: location,
            baseCurrency: baseCurrency,
            preselectedCategory: preselectedCategory,
            onDelete: nil
        )
    }

    private init(
        expense: Expense?,
        location: Location,
        baseCurrency: Currency,
        preselectedCategory: ExpenseCategory? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        let viewModel: ExpenseEditViewModel
        if let expense {
            viewModel = ExpenseEditViewModel(expense: expense, baseCurrency: baseCurrency)
        } else {
            viewModel = ExpenseEditViewModel(
                location: location,
                baseCurrency: baseCurrency,
                preselectedCategory: preselectedCategory
            )
        }
        _viewModel = State(initialValue: viewModel)
        _inputCurrency = State(
            initialValue: viewModel.baseCurrency == viewModel.localCurrency ? .base : .local
        )
        self.onDelete = onDelete
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            expenseEditForm
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.location.screenContextSubtitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .interactiveDismissDisabled(viewModel.hasChanges)
                .scrollDismissesKeyboard(.interactively)
                .notificationAlert(
                    isPresented: rateErrorBinding,
                    title: .exchangeRateLoadingErrorTitle,
                    message: .exchangeRateLoadingErrorMessage(
                        errorDescription: viewModel.rateLoadingError?.errorDescription
                        ?? String(localized: .errorUnknown)
                    )
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

    // MARK: Form Content
    private var expenseEditForm: some View {
        Form {
            dateSection
            specificationsSection
            amountSection
            commentSection
            actionsSection
        }
    }
    
    // MARK: - Section. Date
    private var dateSection: some View {
        Section {
            DatePicker(
                .expenseDate,
                selection: $viewModel.date,
                in: viewModel.location.range
            )
        }
    }
    
    // MARK: - Section. Specification
    private var specificationsSection: some View {
        Section {
            LabeledPicker(
                title: .expenseCategory,
                selection: categoryBinding,
                options: ExpenseCategory.allCases
            ) { category in
                ExpenseCategoryLabel(category: category)
            }
            LabeledPicker(
                title: .expensePaymentMethod,
                selection: paymentMethodBinding,
                options: PaymentMethod.allCases
            ) { method in
                PaymentMethodLabel(method: method)
            }
        }
    }
    
    // MARK: - Section. Amount
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
            }
            
            if viewModel.showsExchangeAdjustmentInput {
                LabeledContent(.locationExchangeAdjustmentPercentage) {
                    HStack {
                        NumericInputField.standard(
                            exchangeAdjustmentInputBinding,
                            focusedField: $focusedField,
                            focusId: .exchangeAdjustmentPercentage,
                            fractionDigits: 2
                        )
                        Image(systemName: "percent")
                            .fontWeight(.semibold)
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Section. Additional
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

    // MARK: - Toolbar
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
        
        ToolbarItemGroup(placement: .keyboard) {
            if focusedField != nil {
                Spacer()
                ToolbarButton.ok {
                    focusedField = nil
                }
            }
        }
    }

    // MARK: - Bindings
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
            get: { viewModel.exchangeAdjustmentPercentage },
            set: { newValue in
                viewModel.updateExchangeAdjustmentPercentage(newValue, currentInput: inputCurrency)
            }
        )
    }
    
    // MARK: - Actions
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

// MARK: - Preview
private extension ExpenseEditView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withNewExpense: Bool = false
    ) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let container = builder.buildContainer()
        let location = builder.fetchLocation(from: container)
        let expense = withNewExpense ? nil : builder.fetchExpense(from: container)

        return Group {
            if let expense {
                ExpenseEditView(expense: expense, baseCurrency: Currency.rub)
            } else {
                ExpenseEditView(location: location, baseCurrency: Currency.rub)
            }
        }
        .modelContainer(container)
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
