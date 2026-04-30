//
//  PaymentMethod+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension PaymentMethod {
    static func from(_ name: String) -> PaymentMethod {
        PaymentMethod(rawValue: name.lowercased()) ?? .defaultValue
    }
}
