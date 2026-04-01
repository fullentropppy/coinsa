//
//  ExpenseCategory+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import SwiftUI

extension ExpenseCategory {
    var localized: LocalizedStringResource {
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
