//
//  TodaySummaryCalculator.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import Foundation

/// Подготавливает список и сводку дня за один проход по расходам локации.
enum TodaySummaryCalculator {
    /// Рассчитывает сводку и подготавливает список трат и быстрые подкатегории одного дня.
    /// - Parameters:
    ///   - location: Локация с бюджетом, валютами и историей трат; сохраненные значения не изменяются.
    ///   - day: Календарный день для фильтрации гражданских дат трат и расчета оставшихся дней.
    ///   - showsLocationBudgetOnOverspend: Разрешает переключение бюджета и остатка на всю локацию при перерасходе.
    ///   - overspendThreshold: Допустимое превышение дневного бюджета в процентах от 0 до 100; переключение требует строгого превышения порога.
    /// - Returns: Сводка с расходами выбранного дня в обеих валютах, отсортированные от новых к старым траты и быстрые подкатегории.
    static func calculate(
        for location: Location,
        on day: PlainDate,
        showsLocationBudgetOnOverspend: Bool,
        overspendThreshold: Double
    ) -> TodaySummary {
        let todayRange = day.startOfDay...day.endOfDay
        let endOfYesterday = day.adding(days: -1).endOfDay
        let previousRange = min(location.startPlainDate.startOfDay, endOfYesterday)...endOfYesterday
        let isHomeLocation = location.homeCurrency == location.locationCurrency
        var todayExpenses: [Expense] = []
        var subcategoryCounts: [ExpenseSubcategory: Int] = [:]
        var todayHomeAmount = 0.0
        var todayLocationAmount = 0.0
        var previousHomeAmount = 0.0
        var previousLocationAmount = 0.0
        var totalHomeAmount = 0.0
        var totalLocationAmount = 0.0

        for expense in location.expenses ?? [] {
            let date = expense.civilDateTime.storedDate
            let homeAmount = expense.amount(in: .home)
            let locationAmount = isHomeLocation ? 0 : expense.amount(in: .location)
            subcategoryCounts[expense.subcategory, default: 0] += 1
            totalHomeAmount += homeAmount
            totalLocationAmount += locationAmount

            if todayRange.contains(date) {
                todayExpenses.append(expense)
                todayHomeAmount += homeAmount
                todayLocationAmount += locationAmount
            }

            if previousRange.contains(date) {
                previousHomeAmount += homeAmount
                previousLocationAmount += isHomeLocation ? 0 : expense.amount(in: .location, using: .actual)
            }
        }

        todayExpenses.sort { $0.civilDateTime > $1.civilDateTime }

        var budgetHomeAmount = location.calculateDailyBudgetAmount(on: day, expensesBeforeDay: previousHomeAmount)
        let switchLimit = max(0, budgetHomeAmount) * (1 + overspendThreshold / 100)
        let comparisonTolerance = max(todayHomeAmount.ulp, switchLimit.ulp) * 8
        let showsLocationBudget = showsLocationBudgetOnOverspend
            && location.hasBudget
            && budgetHomeAmount.isFinite
            && todayHomeAmount.isFinite
            && overspendThreshold.isFinite
            && (0...100).contains(overspendThreshold)
            && switchLimit.isFinite
            && todayHomeAmount - switchLimit > comparisonTolerance

        let budgetLocationAmount: Double?
        let balanceExpensesHomeAmount: Double
        let balanceExpensesLocationAmount: Double

        if showsLocationBudget {
            budgetHomeAmount = location.budget
            budgetLocationAmount = isHomeLocation ? nil : location.calculateBudgetAmount(in: .location)
            balanceExpensesHomeAmount = totalHomeAmount
            balanceExpensesLocationAmount = totalLocationAmount
        } else {
            budgetLocationAmount = isHomeLocation ? nil : location.calculateDailyBudgetAmount(
                on: day,
                in: .location,
                expensesBeforeDay: previousLocationAmount
            )
            balanceExpensesHomeAmount = todayHomeAmount
            balanceExpensesLocationAmount = todayLocationAmount
        }

        let summaryData = EventSummaryData(
            badgeProvider: Location.self,
            dateRangeProvider: location,
            budgetTitle: showsLocationBudget ? .amountBudgetLocation : .amountBudget,
            budgetHomeAmount: budgetHomeAmount,
            expensesHomeAmount: todayHomeAmount,
            homeCurrency: location.homeCurrency,
            budgetLocationAmount: budgetLocationAmount,
            expensesLocationAmount: isHomeLocation ? nil : todayLocationAmount,
            locationCurrency: location.locationCurrency,
            homeAmountBalance: budgetHomeAmount - balanceExpensesHomeAmount,
            locationAmountBalance: budgetLocationAmount.map { $0 - balanceExpensesLocationAmount }
        )

        return TodaySummary(
            data: summaryData,
            expenses: todayExpenses,
            quickExpenseSubcategories: QuickExpenseSubcategories.select(from: subcategoryCounts)
        )
    }
}

/// Согласованные данные сводки, списка и быстрых подкатегорий одного дня.
struct TodaySummary {
    let data: EventSummaryData
    let expenses: [Expense]
    let quickExpenseSubcategories: [ExpenseSubcategory]
}
