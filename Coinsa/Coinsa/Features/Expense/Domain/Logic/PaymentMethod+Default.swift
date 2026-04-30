//
//  PaymentMethod+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension PaymentMethod {
    static var defaultValue: PaymentMethod { PaymentMethod.card }
    static var defaultCode: String { defaultValue.rawValue }
}
