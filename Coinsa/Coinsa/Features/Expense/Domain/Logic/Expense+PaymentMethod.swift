//
//  Expense+PaymentMethod.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension Expense {
    /// Способ оплаты траты (из строкового значения).
    var paymentMethod: PaymentMethod {
        PaymentMethod.from(paymentMethodRaw)
    }
}

