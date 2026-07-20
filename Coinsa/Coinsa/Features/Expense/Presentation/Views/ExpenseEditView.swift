//
//  ExpenseEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI
import SwiftData

/// Экран создания/редактирования траты.
struct ExpenseEditView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние
    
    @State private var viewModel: ExpenseEditViewModel
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var currencySide: CurrencySide
    @State private var isShowingDiscardAlert = false
    
    @FocusState private var focusedField: NumericEditField?
    
    // MARK: - Зависимости
    
    private let onDelete: (() -> Void)?

    // MARK: - Инфраструктура
    
    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }
    
    // MARK: - Инициализация
    
    /// Создает экран для новой траты.
    /// - Parameters:
    ///   - location: Локация траты.
    ///   - preselectedCategory: Предустановленная категория.
    ///   - preselectedPaymentMethod: Предустановленный способ оплаты.
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
    
    /// Создает экран для редактирования существующей траты.
    /// - Parameters:
    ///   - expense: Редактируемая трата.
    ///   - onDelete: Действие после удаления.
    init(forEdit expense: Expense, onDelete: (() -> Void)? = nil) {
        let viewModel = ExpenseEditViewModel(forEdit: expense)
        self.init(initialViewModel: viewModel, onDelete: onDelete)
    }
    
    private init(initialViewModel: ExpenseEditViewModel, onDelete: (() -> Void)? = nil) {
        _viewModel = State(initialValue: initialViewModel)
        _currencySide = State(
            initialValue: initialViewModel.baseCurrency == initialViewModel.expenseCurrency ? .base : .quote
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
            amountSection
            specificationsSection
            currencySection
            dateSection
            commentSection
            actionsSection
        }
    }
    
    // MARK: - Секции
    
    private var amountSection: some View {
        Section {
            VStack {
                NumericInputField(
                    amountInputBinding,
                    focusedField: $focusedField,
                    focusId: .amount,
                    fractionDigits: 2,
                    font: .largeTitle,
                    textAlignment: .center
                )
                HStack {
                    CurrencyCodeText.standard(viewModel.currency(for: currencySide))
                    if !viewModel.isExpenseBaseCurrency {
                        InputCurrencySwitchButton(action: switchInputCurrency)
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
    }
    
    private var specificationsSection: some View {
        Section {
            Picker(selection: categoryBinding) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Image(systemName: category.primaryIcon)
                        .tag(category.id)
                }
            } label: {
                EmptyView()
            }
            .onChange(of: categoryBinding.id) {
                haptics.trigger(.tap)
            }
            .pickerStyle(.segmented)
            .navigationLinkIndicatorVisibility(.hidden)
            .listRowSeparator(.hidden)
            
            LabeledPicker(
                title: viewModel.category.localizedResource,
                selection: subcategoryBinding,
                options: viewModel.category.subcategories
            ) { subcategory in
                subcategory.makeLabel()
            }
        }
    }
    
    private var currencySection: some View {
        Section {
            Picker(.expensePaymentMethod, selection: paymentMethodBinding) {
                ForEach(PaymentMethod.allCases, id: \.self) { paymentMethod in
                    Image(systemName: paymentMethod.primaryIcon)
                       .tag(paymentMethod.id)
                }
            }
            .onChange(of: paymentMethodBinding.id) {
                haptics.trigger(.tap)
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
            
            LabeledPicker(
                title: .expenseCurrency,
                selection: expenseCurrencyBinding,
                options: Currency.allCasesSortedByName
            ) { currency in
                currency.makeLabel()
            }
            
            if viewModel.showsRateExpenseToBase {
                LabeledContent(.expenseExchangeRate(localCurrencyCode: viewModel.expenseCurrency.code)) {
                    ExchangeRateInputField.standard(
                        rateExpenseToBaseInputBinding,
                        currency: viewModel.baseCurrency,
                        isLoading: viewModel.isRateExpenseToBaseLoading,
                        focusedField: $focusedField,
                        focusId: .exchangeRate,
                        onRefresh: { viewModel.requestRateExpenseToBaseRefresh(for: currencySide) }
                    )
                }
            }
            
            if viewModel.showsRateExpenseToLocation {
                LabeledContent(.expenseExchangeRate(localCurrencyCode: viewModel.expenseCurrency.code)) {
                    ExchangeRateInputField.standard(
                        rateExpenseToLocationInputBinding,
                        currency: viewModel.locationCurrency,
                        isLoading: viewModel.isRateExpenseToLocationLoading,
                        focusedField: $focusedField,
                        focusId: .locationExchangeRate,
                        onRefresh: { viewModel.requestRateExpenseToLocationRefresh() }
                    )
                }
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
        } footer: {
            if let adjustedRateDescription = viewModel.adjustedRateDescription {
                Text(adjustedRateDescription)
            }
        }
    }
    
    private var dateSection: some View {
        Section {
            DatePicker(
                selection: $viewModel.date
            ) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text(.expenseDate)
                }
            }
            .environment(\.timeZone, .utc)
        } footer: {
            Text(
                .expenseTimeZoneHint(
                    gmtOffsetDisplay: viewModel.timeZone.gmtOffsetDisplay,
                    timeZoneId: viewModel.timeZone.identifier
                )
            )
        }
    }
    
    private var commentSection: some View {
        Section {
            HStack {
                Image(systemName: "ellipsis.bubble")
                    .foregroundStyle(.secondary)
                
                TextField(.expenseComment, text: $viewModel.comment)
            }
        }
    }

    @ViewBuilder
    private var actionsSection: some View {
        if viewModel.isEdit {
            Section {
                Button(role: .destructive) {
                    requestDelete()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text(.expenseDelete)
                    }
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
            set: { viewModel.updateCategory($0) }
        )
    }
    
    private var subcategoryBinding: Binding<ExpenseSubcategory> {
        Binding(
            get: { viewModel.subcategory },
            set: { viewModel.subcategory = $0 }
        )
    }

    private var paymentMethodBinding: Binding<PaymentMethod> {
        Binding(
            get: { viewModel.paymentMethod },
            set: { newMethod in
                viewModel.updatePaymentMethod(newMethod, currencySide: currencySide)
                settingsStore.selectedPaymentMethod = newMethod
            }
        )
    }
    
    private var expenseCurrencyBinding: Binding<Currency> {
        Binding(
            get: { viewModel.expenseCurrency },
            set: { newCurrency in
                viewModel.updateExpenseCurrency(newCurrency, currencySide: currencySide)
            }
        )
    }
    
    private var amountInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.amount(for: currencySide) },
            set: { newValue in
                viewModel.updateAmount(newValue, for: currencySide)
            }
        )
    }
    
    private var rateExpenseToBaseInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.rateExpenseToBase },
            set: { newValue in
                viewModel.updateRateExpenseToBase(newValue, currencySide: currencySide)
            }
        )
    }
    
    private var rateExpenseToLocationInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.rateExpenseToLocation },
            set: { newValue in
                viewModel.updateRateExpenseToLocation(newValue)
            }
        )
    }
    
    private var rateErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.rateLoadingError != nil },
            set: { shows in
                if !shows {
                    viewModel.rateLoadingError = nil
                }
            }
        )
    }
    
    private var exchangeAdjustmentInputBinding: Binding<Double> {
        Binding(
            get: { viewModel.exchangeAdjustment },
            set: { newValue in
                viewModel.updateExchangeAdjustment(newValue, currencySide: currencySide)
            }
        )
    }
    
    // MARK: - Действия
    
    private func switchInputCurrency() {
        switch currencySide {
        case .base:
            currencySide = .quote
        case .quote:
            currencySide = .base
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
        let builder = PreviewBuilder.builder()
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
