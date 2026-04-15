//
//  ExpenseCategory+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension ExpenseCategory: LocalizedResourceProviding {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .food: .expenseCategoryFood
        case .transport: .expenseCategoryTransport
        case .activity: .expenseCategoryActivity
        case .shopping: .expenseCategoryShopping
        case .medicine: .expenseCategoryMedicine
        case .other: .expenseCategoryOther
        }
    }
}
