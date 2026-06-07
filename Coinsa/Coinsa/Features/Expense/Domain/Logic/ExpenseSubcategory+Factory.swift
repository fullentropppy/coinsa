//
//  ExpenseSubcategory+Factory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension ExpenseSubcategory {
    /// Создает подкатегорию траты по строковому имени.
    /// - Parameter name: Строковое представление подкатегории.
    /// - Returns: Подкатегория траты или значение по умолчанию.
    static func from(_ name: String) -> ExpenseSubcategory {
        ExpenseSubcategory(rawValue: name) ?? .defaultValue
    }
}
