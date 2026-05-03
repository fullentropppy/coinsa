//
//  PaymentMethod+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension PaymentMethod {
    /// Создает способ оплаты по строковому имени.
    /// - Parameter name: Строковое представление способа оплаты.
    /// - Returns: Способ оплаты или значение по умолчанию.
    static func from(_ name: String) -> PaymentMethod {
        PaymentMethod(rawValue: name.lowercased()) ?? .defaultValue
    }
}
