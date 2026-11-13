//
//  LocationRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

/// Строка для отображения локации в списке.
struct LocationRowView: View {
    // MARK: - Свойства
    
    let location: Location
    private let showsBudgetBalance: Bool
    
    // MARK: - Инициализация
    
    /// Создает строку для отображения локации.
    /// - Parameters:
    ///   - location: Локация для отображения.
    ///   - showsBudgetBalance: Показывать остаток бюджета вместо счетчиков трат и дней.
    init(_ location: Location, showsBudgetBalance: Bool = false) {
        self.location = location
        self.showsBudgetBalance = showsBudgetBalance
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
                upperStack
                lowerStack
            }
            if showsBudgetBalance {
                Spacer()
                AmountStack(
                    homeAmount: location.calculateBudgetBalance(in: .home),
                    homeCurrency: location.homeCurrency,
                    expenseAmount: location.calculateBudgetBalance(in: .location),
                    expenseCurrency: location.locationCurrency
                )
            }
        }
    }
    
    // MARK: - Компоненты
    
    private var upperStack: some View {
        HStack(spacing: ViewLayout.Row.metadataSpacing) {
            location.status.makeDot()
            Text(location.name).fontWeight(.semibold)
        }
    }
    
    private var lowerStack: some View {
        HStack(spacing: ViewLayout.Row.metadataSpacing) {
            DateLabel.secondarySmall(from: location.startPlainDate, to: location.endPlainDate)
            if !showsBudgetBalance {
                Spacer()
                CountLabel.secondarySmall(location.expensesCount, icon: Expense.primaryIcon)
                DotDivider.secondarySmall()
                CountLabel.daysSecondarySmall(location.totalDays)
            }
        }
    }
}

// MARK: - Превью

#Preview("Ordinary") {
    List {
        LocationRowView(PreviewGenerator.makeExampleLocation(includeExpenses: true))
    }
}

#Preview("Budget Balance") {
    List {
        LocationRowView(
            PreviewGenerator.makeExampleLocation(includeExpenses: true),
            showsBudgetBalance: true
        )
    }
}
