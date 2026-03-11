//
//  ExpenseCategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation

enum ExpenseCategory: String, Codable, CaseIterable {
    // MARK: - Cases
    case food
    case transport
    case activity
    case shopping
    case medicine
    case other
    
    // MARK: - Computed Properties
    
    var id: String { rawValue }
}
