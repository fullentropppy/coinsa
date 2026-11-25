//
//  TripGeneralExpensesViewModel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.11.2026.
//

import Foundation

/// Сводка и полный список общих трат поездки без дневных ограничений.
struct TripGeneralExpensesViewModel {
    // MARK: - Свойства

    let trip: Trip

    var expenses: [Expense] {
        (trip.generalExpenses ?? []).filter { $0.isGeneralExpense && $0.owningTrip === trip }
    }

    var summaryData: EventSummaryData {
        EventSummaryData(
            budgetHomeAmount: trip.generalExpensesBudget,
            expensesHomeAmount: trip.calculateGeneralExpensesAmount(),
            homeCurrency: trip.homeCurrency
        )
    }

    var groupedExpenses: [(date: CivilDateTime, expenses: [Expense])] {
        Dictionary(grouping: expenses) { CivilDateTime($0.civilDateTime.startOfDay) }
            .sorted { $0.key > $1.key }
            .map { date, expenses in
                (date, expenses.sorted {
                    if $0.civilDateTime != $1.civilDateTime {
                        return $0.civilDateTime > $1.civilDateTime
                    }
                    return $0.id.uuidString < $1.id.uuidString
                })
            }
    }
}
