//
//  EventDayExpenseAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.11.2026.
//

import Foundation

/// Суммы трат выбранного гражданского дня и накопительные значения в течение дня.
struct EventDayExpenseAnalyticsData {
    struct CumulativePoint {
        let hour: Double
        let homeAmount: Double
    }

    let expenses: [Expense]
    let cumulativePoints: [CumulativePoint]
    let homeAmount: Double
    let locationAmount: Double?

    /// Подготавливает суммы без округления и пересчета гражданского времени в пояс устройства.
    /// - Parameters:
    ///   - date: Выбранный календарный день.
    ///   - expenses: Траты исходного события.
    ///   - includesLocationAmount: Рассчитывать дополнительную сумму в валюте локации.
    init(date: PlainDate, expenses: [Expense], includesLocationAmount: Bool) {
        let dayExpenses = expenses.filter {
            PlainDate($0.civilDateTime.storedDate, using: .utc) == date
        }
        var cumulativePoints = [CumulativePoint(hour: 0, homeAmount: 0)]
        var homeAmount = 0.0
        var locationAmount = 0.0

        for expense in dayExpenses.sorted(by: { $0.civilDateTime < $1.civilDateTime }) {
            let storedDate = expense.civilDateTime.storedDate
            let hour = storedDate.timeIntervalSince(date.storedDate) / 3600
            homeAmount += expense.homeAmount
            if includesLocationAmount {
                locationAmount += expense.amount(in: .location)
            }

            if cumulativePoints.last?.hour == hour {
                cumulativePoints.removeLast()
            }
            cumulativePoints.append(CumulativePoint(hour: hour, homeAmount: homeAmount))
        }
        cumulativePoints.append(CumulativePoint(hour: 24, homeAmount: homeAmount))

        self.expenses = dayExpenses
        self.cumulativePoints = cumulativePoints
        self.homeAmount = homeAmount
        self.locationAmount = includesLocationAmount ? locationAmount : nil
    }
}
