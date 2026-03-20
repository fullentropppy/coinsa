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
    @State private var deletionHandler = DeletionHandler<Expense>()

    // MARK: - Computed Properties

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }
    
    // MARK: - Initialization

    init(location: Location, baseCurrency: Currency) {
        _viewModel = State(
            initialValue: ExpenseViewModel(
                location: location,
                baseCurrency: baseCurrency
            )
        )
    }

    init(expense: Expense, baseCurrency: Currency) {
        _viewModel = State(
            initialValue: ExpenseViewModel(
                expense: expense,
                baseCurrency: baseCurrency
            )
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        Form {
            mainDataSection
            amountSection
            commentSection
            actionsSection
        }
        .navigationTitle(viewModel.navigationTitle)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
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
        .overlay {
            EventSummaryView(
                symbolName: "mappin.and.ellipse",
                name: viewModel.location.name,
                startDate: viewModel.location.startDate,
                endDate: viewModel.location.endDate
            )
        }
    }

    // MARK: - Components
    
    private var mainDataSection: some View {
        Section {
            DatePicker("expense.date", selection: $viewModel.date)
            
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
            LabeledContent {
                HStack {
                    TextField("", value: $viewModel.amountInLocalCurrency, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    
                    CurrencyCodeText(viewModel.localCurrency)
                        .frame(width: 40, alignment: .center)
                }
            } label: {
                Text("expense.amount")
            }
            
            LabeledContent {
                HStack {
                    TextField("", value: $viewModel.rateToBaseCurrency, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    
                    CurrencyCodeText(viewModel.baseCurrency)
                        .frame(width: 40, alignment: .center)
                }
            } label: {
                Text("expense.exchangeRate")
            }
        } footer: {
            Text(viewModel.convertedAmountText)
                .frame(maxWidth: .infinity, alignment: .center)
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
        ToolbarItemGroup(placement: .topBarLeading) {
            ButtonView.close {
                dismiss()
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.save {
                viewModel.save(using: repository)
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func requestDelete() {
        guard let expense = viewModel.expenseToEdit else { return }
        deletionHandler.requestDelete(for: [expense])
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { repository.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
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

        return NavigationStack {
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
