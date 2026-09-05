//
//  ExpenseRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI

/// Строка для отображения траты в списке.
struct ExpenseRowView: View {
    // MARK: - Свойства

    private let expense: Expense
    
    // MARK: - Инициализация
    
    /// Создает строку для отображения траты.
    /// - Parameter expense: Трата для отображения.
    init(_ expense: Expense) {
        self.expense = expense
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
            expense.subcategory.makeBadge()
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                DateLabel.secondarySmall(expense.civilDateTime)
                commentIcon
            }
            
        }
    }
    
    @ViewBuilder
    private var commentIcon: some View {
        if expense.comment != nil {
            Image(systemName: "ellipsis.bubble")
                .imageScale(.small)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
    
    private var rightStack: some View {
        AmountStack(
            baseAmount: expense.baseAmount,
            baseCurrency: expense.baseCurrency,
            expenseAmount: expense.amount(in: .expense),
            expenseCurrency: expense.expenseCurrency
        )
    }
}

// MARK: - Превью

private extension ExpenseRowView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder()
        let data = builder.buildData()
        let expense = builder.getExpense(from: data)
        
        return List {
            ExpenseRowView(expense)
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
