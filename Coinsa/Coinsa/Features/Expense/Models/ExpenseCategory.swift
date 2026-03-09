//
//  ExpenseCategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import Foundation

enum ExpenseCategory: String, Codable, CaseIterable {
    case food
    case transport
    case activities
    case shopping
    case medicine
    case other
}
