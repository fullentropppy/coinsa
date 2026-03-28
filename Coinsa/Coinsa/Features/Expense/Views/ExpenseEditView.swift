//
//  ExpenseEditView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseEditView: View {
    // MARK: - Stored Properties

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ExpenseEditViewModel
    @State private var inputCurrency: InputCurrency = .location
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var isShowingDiscardAlert = false

    private let onDelete: (() -> Void)?

    // MARK: - Computed Properties

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }
    
    private var categoryBinding: Binding<ExpenseCategory> {
        Binding(
            get: {
                viewModel.category
            },
            set: {
                viewModel.category = $0
            }
        )
    }
    
    private var amountInputCurrencyValue: Currency {
        viewModel.currency(for: inputCurrency)
    }

    private var amountInputBinding: Binding<Double> {
        Binding(
            get: {
                viewModel.amount(for: inputCurrency)
            },
            set: { newValue in
                viewModel.updateAmount(newValue, for: inputCurrency)
            }
        )
    }
    
    private var rateInputBinding: Binding<Double> {
        Binding(
            get: {
                viewModel.rateLocalToBase
            },
            set: { newValue in
                viewModel.rateLocalToBase = newValue
                let currentAmount = viewModel.amount(for: inputCurrency)
                viewModel.updateAmount(currentAmount, for: inputCurrency)
            }
        )
    }
    
    // MARK: - Initialization

    init(location: Location, baseCurrency: Currency) {
        self.init(
            expense: nil,
            location: location,
            baseCurrency: baseCurrency,
            onDelete: nil
        )
    }

    init(
        expense: Expense,
        baseCurrency: Currency,
        onDelete: (() -> Void)? = nil
    ) {
        self.init(
            expense: expense,
            location: expense.location,
            baseCurrency: baseCurrency,
            onDelete: onDelete
        )
    }

    private init(
        expense: Expense?,
        location: Location,
        baseCurrency: Currency,
        onDelete: (() -> Void)? = nil
    ) {
        let viewModel: ExpenseEditViewModel
        if let expense {
            viewModel = ExpenseEditViewModel(expense: expense, baseCurrency: baseCurrency)
        } else {
            viewModel = ExpenseEditViewModel(location: location, baseCurrency: baseCurrency)
        }
        _viewModel = State(initialValue: viewModel)
        self.onDelete = onDelete
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                mainDataSection
                amountSection
                commentSection
                actionsSection
            }
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .scrollDismissesKeyboard(.interactively)
            .interactiveDismissDisabled(viewModel.hasChanges)
            .discardConfirmationAlert(
                isPresented: $isShowingDiscardAlert,
                onConfirm: {
                    dismiss()
                }
            )
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
                message: "expense.delete.message",
                onConfirm: {
                    confirmDelete()
                    dismiss()
                },
                onCancel: {
                    cancelDelete()
                }
            )
        }
    }

    // MARK: - Components
    
    private var mainDataSection: some View {
        Section {
            DatePicker(
                "expense.date",
                selection: $viewModel.date,
                in: viewModel.location.range
            )
            
            Picker("expense.category", selection: categoryBinding) {
                ForEach(ExpenseCategory.allCases, id: \.id) { category in
                    ExpenseCategoryLabel(category: category)
                        .tag(category)
                }
            }
            .pickerStyle(.navigationLink)
        }
    } 

    private var amountSection: some View {
        Section {
            Picker("", selection: $inputCurrency) {
                Text(viewModel.localCurrency.code)
                    .tag(InputCurrency.location)
                Text(viewModel.baseCurrency.code)
                    .tag(InputCurrency.base)
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)

            LabeledContent("expense.amount") {
                HStack {
                    AmountTextField(value: amountInputBinding)
                    CurrencyCodeText(amountInputCurrencyValue)
                        .frame(width: 40, alignment: .center)
                }
            }
            
            LabeledContent("expense.exchangeRate") {
                HStack {
                    AmountTextField(value: rateInputBinding, fractionDigits: 4)
                    CurrencyCodeText(viewModel.baseCurrency)
                        .frame(width: 40, alignment: .center)
                }
            }
        }
    }

    private var commentSection: some View {
        Section {
            TextField("expense.comment", text: $viewModel.comment)
        }
    }

    private var actionsSection: some View {
        Section {
            if viewModel.isEditing {
                Button("expense.delete", role: .destructive) {
                    requestDelete()
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ContextToolbarTitleView(
                title: viewModel.navigationTitle,
                subtitle: viewModel.location.name
            )
        }
        
        ToolbarItemGroup(placement: .topBarLeading) {
            ButtonView.close {
                handleClose()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.save {
                viewModel.save(using: repository)
                dismiss()
            }
            .disabled(!viewModel.canSave)
        }
    }

    // MARK: - Actions
    
    private func handleClose() {
        if viewModel.hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }

    private func requestDelete() {
        guard let expense = viewModel.expense else { return }
        deletionHandler.request(for: [expense])
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
        onDelete?()
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Previews

private extension ExpenseEditView {
    static func preview(
        withExpense: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let container = builder.buildContainer()
        let location = builder.fetchLocation(from: container)
        let expense = withExpense ? builder.fetchExpense(from: container) : nil

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

#Preview("Light - RU") {
    ExpenseEditView.preview(withExpense: true, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseEditView.preview(withExpense: true, locale: PreviewLocale.en.locale, colorScheme: .dark)
}

#Preview("New Expense. Light - RU") {
    ExpenseEditView.preview(withExpense: false, locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("New Expense. Dark - EN") {
    ExpenseEditView.preview(withExpense: false, locale: PreviewLocale.en.locale, colorScheme: .dark)
}
