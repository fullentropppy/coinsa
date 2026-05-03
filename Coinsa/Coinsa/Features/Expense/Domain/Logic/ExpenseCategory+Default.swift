//
//  ExpenseCategory+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension ExpenseCategory {
    /// Категория траты по умолчанию (прочее).
    static var defaultValue: ExpenseCategory { ExpenseCategory.other }
    
    /// Сырое значение категории по умолчанию.
    static var defaultCode: String { defaultValue.rawValue }
}
