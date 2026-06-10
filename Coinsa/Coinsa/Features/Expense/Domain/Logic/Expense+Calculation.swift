//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

extension Expense {
    // MARK: - Публичные свойства
    
    /// Сумма траты в валюте траты.
    var expenseAmount: Double {
        baseAmount * effectiveRateBaseToExpense
    }
    
    /// Сумма траты в валюте локации.
    var localAmount: Double {
        expenseAmount * rateExpenseToLocation
    }
    
    /// Эффективный курс валюты траты к основной (с учетом корректировки).
    var effectiveRateExpenseToBase: Double {
        adjustedRateExpenseToBase
    }
    
    /// Эффективный курс валюты локации к основной (с учетом корректировки курса траты к основной).
    var effectiveRateLocationToBase: Double {
        rateExpenseToLocation > 0 ? adjustedRateExpenseToBase / rateExpenseToLocation : 0
    }
    
    /// Обратный курс (основная валюта к валюте траты).
    var rateBaseToExpense: Double {
        rateExpenseToBase > 0 ? (1 / rateExpenseToBase) : 0
    }
    
    /// Обратный курс (основная валюта к валюте локации).
    var rateBaseToLocal: Double {
        effectiveRateLocationToBase > 0 ? (1 / effectiveRateLocationToBase) : 0
    }
    
    /// Эффективный курс основной валюты к валюте траты (с учетом корректировки).
    var effectiveRateBaseToExpense: Double {
        adjustedRateExpenseToBase > 0 ? (1 / adjustedRateExpenseToBase) : 0
    }
    
    /// Эффективный курс основной валюты к валюте локации (с учетом корректировки).
    var effectiveRateBaseToLocal: Double {
        effectiveRateLocationToBase > 0 ? (1 / effectiveRateLocationToBase) : 0
    }
    
    // MARK: - Приватные свойства
    
    /// Скорректированный курс валюты траты к основной (с учетом корректировки).
    /// Корректировка применяется только если валюты разные и способ оплаты - карта.
    private var adjustedRateExpenseToBase: Double {
        if baseCurrency != expenseCurrency && paymentMethod == .card {
            rateExpenseToBase * (1 + (exchangeAdjustment / 100))
        } else {
            rateExpenseToBase
        }
    }
}
