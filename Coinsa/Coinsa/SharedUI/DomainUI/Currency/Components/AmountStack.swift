//
//  AmountStack.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.08.2026.
//

import SwiftUI

// Компонент с суммами в разных валютах.
struct AmountStack: View {
    // MARK: - Свойства
    
    private var baseAmount: Double
    private var baseCurrency: Currency
    private var expenseAmount: Double?
    private var expenseCurrency: Currency?
    
    // MARK: - Инициализация
    
    /// Создает компонент с суммами в разных валютах.
    /// - Parameters:
    ///   - baseAmount: Сумма в основной валюте.
    ///   - baseCurrency: Основная валюта.
    ///   - expenseAmount: Сумма в валюте траты (опционально).
    ///   - expenseCurrency: Валюта траты (опционально).
    init(
        baseAmount: Double,
        baseCurrency: Currency,
        expenseAmount: Double? = nil,
        expenseCurrency: Currency? = nil
    ) {
        self.baseAmount = baseAmount
        self.baseCurrency = baseCurrency
        self.expenseAmount = expenseAmount
        self.expenseCurrency = expenseCurrency
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if let mainAmount = expenseAmount,
               let mainCurrency = expenseCurrency,
               mainCurrency != baseCurrency {
                AmountText.standard(mainAmount, currency: mainCurrency)
                AmountText.secondarySmall(baseAmount, currency: baseCurrency)
            } else {
                AmountText.standard(baseAmount, currency: baseCurrency)
            }
        }
    }
}

// MARK: - Превью

#Preview {
    List {
        AmountStack(baseAmount: 2500, baseCurrency: .rub)
        AmountStack(baseAmount: 2500, baseCurrency: .rub, expenseAmount: 5000, expenseCurrency: .jpy)
    }
}
