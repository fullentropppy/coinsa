//
//  ExpenseRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI
import SwiftData

struct ExpenseRowView: View {
    // MARK: - Stored Properties

    let expense: Expense
    let baseCurrency: Currency
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    ExpenseCategoryLabel(category: expense.category)
                    EventDateTimeText(dateTime: expense.date)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 10) {
                    AmountText(
                        amount: expense.amountInBaseCurrency,
                        currency: baseCurrency
                    )
                    AmountText(
                        amount: expense.amountInLocationCurrency,
                        currency: Currency.from(expense.location.currencyCode),
                        style: .secondary
                    )
                }
            }
        }
    }
}

// MARK: - Previews

// MARK: - Previews

private extension ExpenseRowView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let data = builder.buildData()
        let expense = builder.getExpense(from: data)
        
        return List {
            ExpenseRowView(
                expense: expense,
                baseCurrency: Currency.defaultOption
            )
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    ExpenseRowView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseRowView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
