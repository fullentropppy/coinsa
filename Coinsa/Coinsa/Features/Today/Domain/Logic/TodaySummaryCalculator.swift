//
//  TodaySummaryCalculator.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import Foundation

/// Подготавливает сводку локации и список дня с общими тратами ее поездки.
enum TodaySummaryCalculator {
    // MARK: - Методы

    /// Рассчитывает сводку и подготавливает список трат и быстрые подкатегории одного дня.
    /// - Parameters:
    ///   - location: Локация с бюджетом, валютами и историей трат; сохраненные значения не изменяются.
    ///   - day: Календарный день для фильтрации гражданских дат трат и расчета оставшихся дней.
    ///   - showsLocationBudgetOnOverspend: Разрешает переключение бюджета и остатка на всю локацию при перерасходе дневных трат без признака исключения.
    ///   - overspendThreshold: Допустимое превышение дневного бюджета в процентах от 0 до 100; переключение требует строгого превышения порога.
    /// - Returns: Сводка дневных трат локации без исключенных сумм, список с общими тратами ее поездки и быстрые подкатегории по истории локации.
    static func calculate(
        for location: Location,
        on day: PlainDate,
        showsLocationBudgetOnOverspend: Bool,
        overspendThreshold: Double
    ) -> TodaySummary {
        let todayRange = day.startOfDay...day.endOfDay
        let isHomeLocation = location.homeCurrency == location.locationCurrency
        var todayExpenses: [Expense] = []
        var subcategoryCounts: [ExpenseSubcategory: Int] = [:]
        var todayHomeAmount = 0.0
        var todayLocationAmount = 0.0
        var reservedHomeAmount = 0.0
        var reservedLocationAmount = 0.0
        var totalHomeAmount = 0.0
        var totalLocationAmount = 0.0

        for expense in location.expenses ?? [] {
            let date = expense.civilDateTime.storedDate
            let isToday = todayRange.contains(date)
            let homeAmount = expense.amount(in: .home)
            let locationAmount = isHomeLocation ? 0 : expense.amount(in: .location)
            subcategoryCounts[expense.subcategory, default: 0] += 1
            totalHomeAmount += homeAmount
            totalLocationAmount += locationAmount

            if isToday {
                todayExpenses.append(expense)
            }

            if isToday && !expense.isExcludedFromDailySpending {
                todayHomeAmount += homeAmount
                todayLocationAmount += locationAmount
            } else {
                reservedHomeAmount += homeAmount
                reservedLocationAmount += isHomeLocation ? 0 : expense.amount(in: .location, using: .actual)
            }
        }

        if let trip = location.trip {
            todayExpenses += (trip.generalExpenses ?? []).filter {
                $0.isGeneralExpense && $0.owningTrip === trip && todayRange.contains($0.civilDateTime.storedDate)
            }
        }
        todayExpenses.sort {
            if $0.civilDateTime != $1.civilDateTime { return $0.civilDateTime > $1.civilDateTime }
            return $0.id.uuidString < $1.id.uuidString
        }

        var budgetHomeAmount = location.calculateDailyBudgetAmount(on: day, reservedExpensesAmount: reservedHomeAmount)
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
                reservedExpensesAmount: reservedLocationAmount
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
    // MARK: - Свойства

    let data: EventSummaryData
    let expenses: [Expense]
    let quickExpenseSubcategories: [ExpenseSubcategory]
}
