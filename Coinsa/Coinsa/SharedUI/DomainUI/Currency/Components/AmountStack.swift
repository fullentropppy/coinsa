//
//  AmountStack.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.08.2026.
//

import SwiftUI

/// Компонент с суммами в разных валютах.
struct AmountStack: View {
    // MARK: - Свойства
    
    private let homeAmount: Double
    private let homeCurrency: Currency
    private let expenseAmount: Double?
    private let expenseCurrency: Currency?
    private let usesAdaptiveFormatting: Bool
    private let primaryAmountColor: Color
    
    // MARK: - Инициализация
    
    /// Создает компонент с суммами в разных валютах.
    /// - Parameters:
    ///   - homeAmount: Сумма в домашней валюте.
    ///   - homeCurrency: Домашняя валюта.
    ///   - expenseAmount: Сумма в валюте траты (опционально).
    ///   - expenseCurrency: Валюта траты (опционально).
    ///   - usesAdaptiveFormatting: Сокращать суммы при нехватке ширины. По умолчанию `true`.
    ///   - primaryAmountColor: Цвет основной суммы без изменения вторичной суммы и кодов валют.
    init(
        homeAmount: Double,
        homeCurrency: Currency,
        expenseAmount: Double? = nil,
        expenseCurrency: Currency? = nil,
        usesAdaptiveFormatting: Bool = true,
        primaryAmountColor: Color = .primary
    ) {
        self.homeAmount = homeAmount
        self.homeCurrency = homeCurrency
        self.expenseAmount = expenseAmount
        self.expenseCurrency = expenseCurrency
        self.usesAdaptiveFormatting = usesAdaptiveFormatting
        self.primaryAmountColor = primaryAmountColor
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .trailing, spacing: ViewLayout.Row.contentSpacing) {
            if let mainAmount = expenseAmount,
               let mainCurrency = expenseCurrency,
               mainCurrency != homeCurrency {
                AmountText
                    .standard(
                        mainAmount,
                        currency: mainCurrency,
                        color: primaryAmountColor,
                        usesAdaptiveFormatting: usesAdaptiveFormatting
                    )
                AmountText
                    .secondarySmall(
                        homeAmount,
                        currency: homeCurrency,
                        usesAdaptiveFormatting: usesAdaptiveFormatting
                    )
            } else {
                AmountText
                    .standard(
                        homeAmount,
                        currency: homeCurrency,
                        color: primaryAmountColor,
                        usesAdaptiveFormatting: usesAdaptiveFormatting
                    )
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

// MARK: - Превью

#Preview {
    List {
        AmountStack(homeAmount: 2500, homeCurrency: .rub)
        AmountStack(homeAmount: 2500, homeCurrency: .rub, expenseAmount: 5000, expenseCurrency: .jpy)
    }
}

#Preview("Large amounts") {
    VStack(spacing: 20) {
        AmountStack(
            homeAmount: 24600,
            homeCurrency: .rub,
            expenseAmount: 750000,
            expenseCurrency: .vnd,
            usesAdaptiveFormatting: true
        )
        AmountStack(
            homeAmount: 42000,
            homeCurrency: .rub,
            expenseAmount: 12500000,
            expenseCurrency: .vnd,
            usesAdaptiveFormatting: true
        )
        AmountStack(
            homeAmount: -2500000000,
            homeCurrency: .vnd,
            usesAdaptiveFormatting: true
        )
    }
    .frame(width: 140)
}
