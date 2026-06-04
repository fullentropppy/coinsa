//
//  ExpenseSubcategory+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension ExpenseSubcategory {
    /// Подкатегория траты по умолчанию (прочее).
    static var defaultValue: ExpenseSubcategory { ExpenseSubcategory.other }
    
    /// Сырое значение подкатегории по умолчанию.
    static var defaultCode: String { defaultValue.rawValue }
}
