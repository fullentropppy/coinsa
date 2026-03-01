//
//  ExpenseRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.03.2026.
//

import SwiftUI

struct ExpenseRowView: View {
    // MARK: - Stored properties
    
    let expense: Expense
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.date, format: .dateTime.year().month().day())
                Text(expense.category.localized)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(
                expense.amountInLocationCurrency,
                format: .currency(code: expense.location.locationCurrencyCode)
            )
        }
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    ExpenseRowView(expense: PreviewDataFactory.Builder().buildFirstExpense())
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    ExpenseRowView(expense: PreviewDataFactory.Builder().buildFirstExpense())
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}
