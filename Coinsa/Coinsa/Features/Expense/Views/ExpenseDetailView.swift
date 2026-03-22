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

    // MARK: - Computed Properties
    
    private var baseCurrency: Currency {
        settingsStore.baseCurrency
    }
    
    private var localCurrency: Currency {
        Currency.from(expense.location.currencyCode)
    }
    
    // MARK: - Body

    var body: some View {
        List {
            mainSection
            
            if let comment = expense.comment {
                commentSection(comment: comment)
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingExpenseEdit) {
            ExpenseEditView(
                expense: expense,
                baseCurrency: baseCurrency
            )
        }
    }

    // MARK: - Components

    private var mainSection: some View {
        Section {
            VStack(spacing: 16) {
                DateLabel(single: expense.date, style: .secondary)
                
                Spacer()

                AmountText(
                    expense.amountInLocalCurrency,
                    currency: localCurrency
                )
                .scaleEffect(2.2)
                .frame(height: 40)
                
                amountSectionDevider
                
                VStack(spacing: 14) {
                    AmountText(
                        expense.amountInBaseCurrency,
                        currency: baseCurrency,
                        style: .secondary
                    )
                    .scaleEffect(1.6)
                    
                    ExchangeRateText(
                        from: localCurrency,
                        to: baseCurrency,
                        rate: expense.rateToBaseCurrency,
                        style: .secondary)
                }
                
                amountSectionDevider
                
                Image(systemName: expense.category.symbolName)
                    .foregroundStyle(.accent)
                    .scaleEffect(1.2)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 300, alignment: .top)
        }
    }
    
    private var amountSectionDevider: some View {
        Divider().frame(maxWidth: 160, maxHeight: 10)
    }
    
    private func commentSection(comment: String) -> some View {
        Section {
            Text(comment)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ContextToolbarTitleView(
                title: expense.category.localizedDisplayName,
                subtitle: expense.location.name
            )
        }
        
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
