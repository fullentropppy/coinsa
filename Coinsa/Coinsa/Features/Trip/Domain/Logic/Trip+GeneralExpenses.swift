//
//  Trip+GeneralExpenses.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.11.2026.
//

import Foundation

extension Trip {
    // MARK: - Свойства

    /// Наличие общих трат блокирует изменение домашней валюты даже без локаций.
    var hasGeneralExpenses: Bool {
        generalExpenses?.isEmpty == false
    }

    var generalExpensesCount: Int {
        (generalExpenses ?? []).filter { $0.isGeneralExpense && $0.owningTrip === self }.count
    }

    /// Домашнюю валюту можно изменить только до добавления локаций и общих трат.
    var canChangeHomeCurrency: Bool {
        !hasLocations && !hasGeneralExpenses
    }

    /// Траты обеих областей с единственным владельцем этой поездки.
    var allExpenses: [Expense] {
        let locationExpenses = (locations ?? []).flatMap { $0.expenses ?? [] }
        return (locationExpenses + (generalExpenses ?? [])).filter { $0.owningTrip === self }
    }

    // MARK: - Расчеты

    /// Возвращает общие траты за заданный диапазон в домашней валюте.
    /// - Parameter targetRange: Включенный диапазон гражданских дат или nil для всей истории.
    /// - Returns: Сумма общих трат без трат локаций.
    func calculateGeneralExpensesAmount(withinDateRange targetRange: ClosedRange<Date>? = nil) -> Double {
        (generalExpenses ?? []).reduce(0) { result, expense in
            guard expense.isGeneralExpense, expense.owningTrip === self,
                  targetRange.map({ $0.contains(expense.civilDateTime.storedDate) }) != false else { return result }
            return result + expense.amount(in: .home)
        }
    }
}
