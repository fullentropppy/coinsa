//
//  ExpenseCategory+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension ExpenseCategory: LocalizedResourceProviding {
    // MARK: - Свойства

    /// Локализованное название категории траты.
    var localizedResource: LocalizedStringResource {
        switch self {
        case .food: .expenseCategoryFood
        case .transport: .expenseCategoryTransport
        case .accommodation: .expenseCategoryAccommodation
        case .leisure: .expenseCategoryLeisure
        case .shopping: .expenseCategoryShopping
        case .medicine: .expenseCategoryMedicine
        case .miscellaneous: .expenseCategoryMiscellaneous
        }
    }
}
