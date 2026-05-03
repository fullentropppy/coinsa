//
//  PaymentMethod+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension PaymentMethod {
    /// Способ оплаты по умолчанию (карта).
    static var defaultValue: PaymentMethod { PaymentMethod.card }
    
    /// Сырое значение способа оплаты по умолчанию.
    static var defaultCode: String { defaultValue.rawValue }
}
