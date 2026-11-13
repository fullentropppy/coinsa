//
//  LocationBudgetTransfer.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

/// Перераспределение всего остатка между бюджетами локаций в домашней валюте.
struct LocationBudgetTransfer {
    enum ValidationError: Error {
        case invalidLocations
        case invalidAmounts
        case balanceChanged
    }

    let homeAmount: Double
    let sourceBudget: Double
    let destinationBudget: Double

    /// Проверяет подтвержденный остаток и рассчитывает новые бюджеты без округления сумм.
    /// - Parameters:
    ///   - source: Локация, передающая остаток бюджета.
    ///   - destination: Локация-получатель в той же поездке.
    ///   - expectedHomeAmount: Сумма, показанная пользователю перед подтверждением.
    ///   - expectedHomeCurrencyCode: Код домашней валюты на момент подтверждения.
    init(
        from source: Location,
        to destination: Location,
        expectedHomeAmount: Double,
        expectedHomeCurrencyCode: String
    ) throws {
        guard source.id != destination.id,
              let trip = source.trip,
              trip === destination.trip else {
            throw ValidationError.invalidLocations
        }

        guard trip.baseCurrencyCode == expectedHomeCurrencyCode,
              let amount = Self.availableHomeAmount(from: source),
              amount == expectedHomeAmount else {
            throw ValidationError.balanceChanged
        }

        let newDestinationBudget = destination.budget + amount
        guard destination.budget.isFinite,
              destination.budget >= 0,
              newDestinationBudget.isFinite,
              newDestinationBudget > destination.budget else {
            throw ValidationError.invalidAmounts
        }

        homeAmount = amount
        sourceBudget = source.calculateExpensesAmount(in: .home)
        destinationBudget = newDestinationBudget
    }

    static func availableHomeAmount(from location: Location) -> Double? {
        let expensesAmount = location.calculateExpensesAmount(in: .home)
        let balance = location.calculateBudgetBalance(in: .home)

        guard location.budget.isFinite,
              expensesAmount.isFinite,
              expensesAmount >= 0,
              balance.isFinite,
              balance > 0 else {
            return nil
        }

        return balance
    }
}
