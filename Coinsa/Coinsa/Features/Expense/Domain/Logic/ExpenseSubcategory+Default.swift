//
//  ExpenseSubcategory+Default.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension ExpenseSubcategory {
    /// Подкатегория траты по умолчанию (прочее).
    static func defaultValue(with category: ExpenseCategory = .miscellaneous) -> ExpenseSubcategory {
        switch category {
        case .food: .otherFood
        case .transport: .otherTransport
        case .accommodation: .otherAccomodation
        case .leisure: .otherLeisure
        case .shopping: .otherShopping
        case .medicine: .otherMedicine
        case .miscellaneous: .otherMiscellaneous
        }
    }
    
    /// Сырое значение подкатегории по умолчанию.
    static func defaultCode(with category: ExpenseCategory = .miscellaneous) -> String {
        defaultValue(with: category).rawValue
    }
}
