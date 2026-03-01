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
                Text(expense.date, format: .dateTime.year().month().day().hour().minute())
                HStack {
                    Image(systemName: expense.category.sfSymbolName).imageScale(.small)
                    Text(expense.category.localized).font(.callout)
                }
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
    List {
        ExpenseRowView(expense: PreviewDataFactory.Builder().buildFirstExpense())
            .environment(\.locale, Locale(identifier: "ru"))
            .preferredColorScheme(.light)
    }
}

#Preview("Dark - EN") {
    List {
        ExpenseRowView(expense: PreviewDataFactory.Builder().buildFirstExpense())
            .environment(\.locale, Locale(identifier: "en"))
            .preferredColorScheme(.dark)
    }
}
