//
//  ExpenseRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI

struct ExpenseRowView: View {
    // MARK: - Stored Properties

    let expense: Expense
    let baseCurrency: Currency
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            leftStack
            Spacer()
            rightStack
        }
    }
    
    // MARK: - Components
    
    private var leftStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            BadgeView(
                fillColor: expense.category.badgeColor,
                icon: expense.category.badgeIcon,
                title: expense.category.localized
            )
            DateLabel.secondarySmall(expense.date)
        }
    }
    
    private var rightStack: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if baseCurrency == expense.localCurrency {
                AmountText.standard(expense.baseAmount, currency: baseCurrency)
                Spacer()
            } else {
                AmountText.standard(expense.localAmount, currency: expense.localCurrency)
                AmountText.secondarySmall(expense.baseAmount,currency: baseCurrency)
            }
        }
    }
}

// MARK: - Previews

private extension ExpenseRowView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let data = builder.buildData()
        let expense = builder.getExpense(from: data)
        
        return List {
            ExpenseRowView(
                expense: expense,
                baseCurrency: Currency.defaultCurrency
            )
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    ExpenseRowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseRowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
