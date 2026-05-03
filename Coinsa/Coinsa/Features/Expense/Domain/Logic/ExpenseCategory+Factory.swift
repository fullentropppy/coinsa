//
//  ExpenseCategory+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension ExpenseCategory {
    /// Создает категорию траты по строковому имени.
    /// - Parameter name: Строковое представление категории.
    /// - Returns: Категория траты или значение по умолчанию.
    static func from(_ name: String) -> ExpenseCategory {
        ExpenseCategory(rawValue: name.lowercased()) ?? .defaultValue
    }
}
