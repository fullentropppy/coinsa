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

    @State private var viewModel: ExpenseViewModel
    @State private var inputCurrency: InputCurrency = .location
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var isShowingDiscardAlert = false

    private let onDelete: (() -> Void)?

    // MARK: - Computed Properties

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
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
        let viewModel: ExpenseViewModel
        if let expense {
            viewModel = ExpenseViewModel(expense: expense, baseCurrency: baseCurrency)
        } else {
            viewModel = ExpenseViewModel(location: location, baseCurrency: baseCurrency)
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
            .interactiveDismissDisabled(hasChanges)
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
            .discardConfirmationAlert(
                isPresented: $isShowingDiscardAlert,
                onConfirm: {
                    dismiss()
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
            
            HStack {
                Picker("expense.category", selection: $viewModel.category) {
                    ForEach(ExpenseCategory.allCases, id: \.id) { category in
                        Text(category.localizedKey).tag(category)
                    }
                }
                .pickerStyle(.menu)
                
                Image(systemName: viewModel.category.symbolName)
                    .foregroundStyle(.secondary)
                    .frame(width: 40, alignment: .center)
            }
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

            LabeledContent {
                HStack {
                    AmountTextField(value: amountInputBinding)
                    
                    CurrencyCodeText(amountInputCurrencyValue)
                        .frame(width: 40, alignment: .center)
                }
            } label: {
                Text("expense.amount")
            }
            
            LabeledContent {
                HStack {
                    AmountTextField(value: $viewModel.rateBaseToLocal)
                    
                    CurrencyCodeText(viewModel.baseCurrency)
                        .frame(width: 40, alignment: .center)
                }
            } label: {
                Text(viewModel.rateBaseToLocalText)
            }
        }
    }

    private var commentSection: some View {
        Section {
            TextField("expense.comment", text: $viewModel.comment, axis: .vertical)
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
            .disabled(!canSave)
        }
    }

    // MARK: - Actions

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

    private var canSave: Bool {
        viewModel.canSave
    }

    private var hasChanges: Bool {
        viewModel.hasChanges
    }

    private func handleClose() {
        if hasChanges {
            isShowingDiscardAlert = true
        } else {
            dismiss()
        }
    }

    private func requestDelete() {
        guard let expense = viewModel.expenseToEdit else { return }
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
