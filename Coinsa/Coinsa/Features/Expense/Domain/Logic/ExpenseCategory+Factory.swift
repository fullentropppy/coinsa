//
//  ExpenseCategory+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension ExpenseCategory {
    static func from(_ name: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: name.lowercased()) ?? .defaultValue
    }
}
