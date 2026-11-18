//
//  EventDayExpenseAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.11.2026.
//

import Foundation

/// Суммы трат выбранного гражданского дня и его 24 часов.
struct EventDayExpenseAnalyticsData {
    let expenses: [Expense]
    let hourlyHomeAmounts: [Double]
    let homeAmount: Double
    let locationAmount: Double?
    let maxHourlyHomeAmount: Double
    let maxHourlyLocationAmount: Double?

    /// Подготавливает суммы без округления и пересчета гражданского времени в пояс устройства.
    /// - Parameters:
    ///   - date: Выбранный календарный день.
    ///   - expenses: Траты исходного события.
    ///   - includesLocationAmount: Рассчитывать дополнительную сумму в валюте локации.
    init(date: PlainDate, expenses: [Expense], includesLocationAmount: Bool) {
        var dayExpenses: [Expense] = []
        var hourlyHomeAmounts = Array(repeating: 0.0, count: 24)
        var hourlyLocationAmounts = Array(repeating: 0.0, count: 24)
        var homeAmount = 0.0
        var locationAmount = 0.0

        for expense in expenses {
            let storedDate = expense.civilDateTime.storedDate
            guard PlainDate(storedDate, using: .utc) == date else { continue }

            dayExpenses.append(expense)
            let amount = expense.homeAmount
            let hour = storedDate.hour(using: .utc)
            hourlyHomeAmounts[hour] += amount
            homeAmount += amount
            if includesLocationAmount {
                let amount = expense.amount(in: .location)
                hourlyLocationAmounts[hour] += amount
                locationAmount += amount
            }
        }

        let peak = hourlyHomeAmounts.enumerated().max { $0.element < $1.element }

        self.expenses = dayExpenses
        self.hourlyHomeAmounts = hourlyHomeAmounts
        self.homeAmount = homeAmount
        self.locationAmount = includesLocationAmount ? locationAmount : nil
        self.maxHourlyHomeAmount = peak?.element ?? 0
        self.maxHourlyLocationAmount = includesLocationAmount ? peak.map { hourlyLocationAmounts[$0.offset] } : nil
    }
}
