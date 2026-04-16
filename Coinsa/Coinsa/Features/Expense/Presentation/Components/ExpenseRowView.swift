//
//  ExpenseRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI

struct ExpenseRowView: View {
    // MARK: - Свойства

    let expense: Expense
    let baseCurrency: Currency
    
    // MARK: - Инициализация
    
    init(_ expense: Expense, baseCurrency: Currency) {
        self.expense = expense
        self.baseCurrency = baseCurrency
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack {
            leftStack
            Spacer()
            rightStack
        }
    }
    
    // MARK: - Компоненты
    
    private var leftStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            expense.category.makeBadge()
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

// MARK: - Превью

private extension ExpenseRowView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withBudgets(false)
        let data = builder.buildData()
        let expense = builder.getExpense(from: data)
        
        return List {
            ExpenseRowView(expense, baseCurrency: Currency.defaultCurrency)
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
