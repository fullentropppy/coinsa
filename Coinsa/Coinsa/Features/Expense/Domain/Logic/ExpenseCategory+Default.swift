//
//  ExpenseCategory+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.04.2026.
//

extension ExpenseCategory {
    static var defaultValue: ExpenseCategory { ExpenseCategory.other }
    static var defaultCode: String { defaultValue.rawValue }
}
