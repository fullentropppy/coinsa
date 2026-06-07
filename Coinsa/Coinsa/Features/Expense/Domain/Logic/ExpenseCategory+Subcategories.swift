//
//  ExpenseCategory+Subcategories.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension ExpenseCategory {
    /// Дочерние подкатегории для категории.
    var subcategories: [ExpenseSubcategory] {
        switch self {
        case .food:
            [.breakfast, .lunch, .dinner, .snack, .groceries, .other]
        case .transport:
            [.plane, .ferry, .train, .publicTransport, .taxi, .transfer, .travelPass, .vehicleRental, .fuel, .other]
        case .accommodation:
            [.hotel, .accommodationRental, .touristTax, .other]
        case .leisure:
            [.tour, .landmark, .park, .activity, .entertainment, .other]
        case .shopping:
            [.clothing, .cosmetics, .souvenirs, .jewelry, .homeGoods, .electronics, .other]
        case .medicine:
            [.healthInsurance, .medicalCare, .medication, .other]
        case .miscellaneous:
            [.connectivity, .bankFees, .documents, .laundry, .donation, .luggageStorage, .postalService, .digitalService, .other]
        }
    }
}
