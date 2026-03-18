//
//  ExpenseDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseDetailView: View {
    // MARK: - Stored Properties

    @Environment(AppSettingsStore.self) private var settingsStore

    @State private var isShowingExpenseEdit = false

    let expense: Expense

    // MARK: - Body

    var body: some View {
        detailContent(
            expense: expense,
            viewModel: ExpenseDetailViewModel(
                expense: expense,
                baseCurrency: settingsStore.baseCurrency
            )
        )
    }

    // MARK: - Components

    private func detailContent(expense: Expense, viewModel: ExpenseDetailViewModel) -> some View {
        List {
            amountBlock(expense: expense, viewModel: viewModel)
 
            if let comment = expense.comment {
                Section("expense.comment") {
                    Text(comment).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(expense.category.localizedKey)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingExpenseEdit) {
            ExpenseEditView(
                location: expense.location,
                expense: expense,
                baseCurrency: settingsStore.baseCurrency
            )
        }
    }

    private func amountBlock(expense: Expense, viewModel: ExpenseDetailViewModel) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar").foregroundStyle(.secondary)
                    EventDateTimeText(dateTime: expense.date)
                }
                HStack(spacing: 12) {
                    amountSubcard(
                        title: "expense.amount.base",
                        amount: expense.amountInBaseCurrency,
                        currency: viewModel.baseCurrency
                    )
                    amountSubcard(
                        title: "expense.amount.local",
                        amount: expense.amountInLocationCurrency,
                        currency: viewModel.localCurrency
                    )
                }
                exchangeRateLabel(expense: expense, viewModel: viewModel)
            }
        }
    }

    private func amountSubcard(
        title: LocalizedStringKey,
        amount: Double,
        currency: Currency
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            CurrencyCodeText(currency: currency)
            AmountText(amount: amount, style: .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.gray.opacity(0.15).gradient)
        )
    }

    private func exchangeRateLabel(
        expense: Expense,
        viewModel: ExpenseDetailViewModel
    ) -> some View {
        let rateText = String(
            format: "%.4f",
            expense.rateToBaseCurrency
        )
        return HStack(spacing: 6) {
            Text("1 \(viewModel.localCurrency.code) = \(rateText) \(viewModel.baseCurrency.code)")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.edit {
                isShowingExpenseEdit = true
            }
        }
    }
    
}

// MARK: - Previews

private extension ExpenseDetailView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let expense = builder.fetchExpense(from: container)

        return NavigationStack {
            ExpenseDetailView(expense: expense)
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ExpenseDetailView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseDetailView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
