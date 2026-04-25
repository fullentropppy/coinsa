//
//  Budget.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.04.2026.
//

struct Budget: Codable, Identifiable, Equatable {
    var category: ExpenseCategory
    var baseAmount: Double
    
    var id: String { category.rawValue }
}
