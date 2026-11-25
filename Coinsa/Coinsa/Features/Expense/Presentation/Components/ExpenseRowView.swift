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
    private let showsDailySpendingExclusion: Bool
    
    private var hasComment: Bool {
        expense.comment != nil
    }
    
    // MARK: - Инициализация
    
    /// Создает строку для отображения траты.
    /// - Parameters:
    ///   - expense: Трата для отображения.
    ///   - showsDailySpendingExclusion: Показывать исключение из дневных трат цветом основной суммы.
    init(_ expense: Expense, showsDailySpendingExclusion: Bool = false) {
        self.expense = expense
        self.showsDailySpendingExclusion = showsDailySpendingExclusion
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
        VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
            expense.subcategory.makeBadge()
            HStack(alignment: .lastTextBaseline, spacing: ViewLayout.Row.metadataSpacing) {
                DateLabel.secondarySmall(expense.civilDateTime)
                if hasComment {
                    DotDivider.secondarySmall()
                    CommentIcon(isCompact: true)
                }
            }
            
        }
    }
    
    private var rightStack: some View {
        AmountStack(
            homeAmount: expense.homeAmount,
            homeCurrency: expense.homeCurrency,
            expenseAmount: expense.amount(in: .expense),
            expenseCurrency: expense.expenseCurrency,
            primaryAmountColor: showsDailySpendingExclusion && expense.isExcludedFromDailySpending ? .secondary : .primary
        )
    }
}

// MARK: - Превью

#Preview {
    List {
        ExpenseRowView(PreviewGenerator.makeExampleExpense())
    }
}
