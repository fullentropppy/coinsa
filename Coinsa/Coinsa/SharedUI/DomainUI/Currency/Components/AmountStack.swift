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
    
    // MARK: - Инициализация
    
    /// Создает компонент с суммами в разных валютах.
    /// - Parameters:
    ///   - homeAmount: Сумма в домашней валюте.
    ///   - homeCurrency: Домашняя валюта.
    ///   - expenseAmount: Сумма в валюте траты (опционально).
    ///   - expenseCurrency: Валюта траты (опционально).
    init(
        homeAmount: Double,
        homeCurrency: Currency,
        expenseAmount: Double? = nil,
        expenseCurrency: Currency? = nil
    ) {
        self.homeAmount = homeAmount
        self.homeCurrency = homeCurrency
        self.expenseAmount = expenseAmount
        self.expenseCurrency = expenseCurrency
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if let mainAmount = expenseAmount,
               let mainCurrency = expenseCurrency,
               mainCurrency != homeCurrency {
                AmountText.standard(mainAmount, currency: mainCurrency)
                AmountText.secondarySmall(homeAmount, currency: homeCurrency)
            } else {
                AmountText.standard(homeAmount, currency: homeCurrency)
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
