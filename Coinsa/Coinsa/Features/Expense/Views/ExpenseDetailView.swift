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
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingExpenseEdit = false

    let expense: Expense

    // MARK: - Computed Properties
    
    private var baseCurrency: Currency {
        settingsStore.baseCurrency
    }
    
    private var localCurrency: Currency {
        Currency.from(expense.location.currencyCodeLocal)
    }
    
    // MARK: - Body

    var body: some View {
        Form {
            mainSection
            if let comment = expense.comment {
                commentSection(comment: comment)
            }
        }
        .navigationTitle(expense.category.localizedKey)
        .navigationSubtitle(expense.location.screenContextSubtitle)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingExpenseEdit) {
            ExpenseEditView(
                expense: expense,
                baseCurrency: baseCurrency,
                onDelete: {
                    isShowingExpenseEdit = false
                    dismiss()
                }
            )
        }
    }

    // MARK: - Components

    private var mainSection: some View {
        Section {
            VStack(spacing: 16) {
                HStack {
                    BadgeView(
                        fillColor: Expense.badgeColor,
                        icon: Expense.badgeIcon
                    )
                    BadgeView(
                        fillColor: expense.category.badgeColor,
                        icon: expense.category.badgeIcon
                    )
                    Spacer()
                    DateLabel(single: expense.date, style: .tertiary)
                }
                
                VStack(alignment: .center, spacing: 6) {
                    AmountText(
                        expense.amountLocal,
                        currency: localCurrency
                    )
                    .padding(40)
                    .scaleEffect(2)
                    
                    Divider()
                    HStack {
                        AmountText(
                            expense.amountBase,
                            currency: baseCurrency,
                            style: .secondary
                        )
                        
                        Text("•").foregroundStyle(.secondary)
                        
                        ExchangeRateText(
                            from: localCurrency,
                            to: baseCurrency,
                            rate: expense.rateLocalToBase,
                            style: .secondary)
                    }
                    .padding(10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .glassEffect(
                    .regular,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
            }
        }
    }
    
    private func commentSection(comment: String) -> some View {
        Section {
            Text(comment)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButtonView.edit {
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
