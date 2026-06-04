//
//  ExpenseSubcategory+ParentCategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension ExpenseSubcategory {
    /// Родительская категория для подкатегории.
    var parentCategory: ExpenseCategory {
        switch self {
        case .breakfast, .lunch, .dinner, .snack, .groceries: .food
        case .plane, .ferry, .train, .publicTransport, .taxi, .transfer, .travelPass, .transportRental, .fuel: .transport
        case .hotel, .accommodationRental, .touristTax: .accommodation
        case .tour, .landmark, .park, .activity, .entertainment: .activity
        case .clothing, .cosmetics, .souvenirs, .jewelry, .homeGoods, .electronics: .shopping
        case .healthInsurance, .medicalCare, .medication: .medicine
        case .connectivity, .bankFee, .document, .laundry, .donation, .luggageStorage, .postalService, .digitalService, .other: .other
        }
    }
}
