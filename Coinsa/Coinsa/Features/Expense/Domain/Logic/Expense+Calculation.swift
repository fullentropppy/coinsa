//
//  Expense+Calculation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 25.03.2026.
//

extension Expense {
    // MARK: - Публичные свойства
    
    /// Сумма траты в локальной валюте.
    var localAmount: Double {
        baseAmount * effectiveRateBaseToLocal
    }
    
    /// Эффективный курс локальной валюты к основной (с учетом корректировки).
    var effectiveRateLocalToBase: Double {
        adjustedRateLocalToBase
    }
    
    /// Обратный курс (основная валюта к локальной).
    var rateBaseToLocal: Double {
        rateLocalToBase > 0 ? (1 / rateLocalToBase) : 0
    }
    
    /// Эффективный курс основной валюты к локальной (с учетом корректировки).
    var effectiveRateBaseToLocal: Double {
        adjustedRateLocalToBase > 0 ? (1 / adjustedRateLocalToBase) : 0
    }
    
    // MARK: - Приватные свойства
    
    /// Скорректированный курс локальной валюты к основной (с учетом корректировки).
    /// Корректировка применяется только если валюты разные и способ оплаты - карта.
    private var adjustedRateLocalToBase: Double {
        if baseCurrency != localCurrency && paymentMethod == .card {
            rateLocalToBase * (1 + (exchangeAdjustment / 100))
        } else {
            rateLocalToBase
        }
    }
}
