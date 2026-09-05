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
            [.breakfast, .lunch, .dinner, .snack, .groceries, .otherFood]
        case .transport:
            [.plane, .ferry, .train, .publicTransport, .taxi, .transfer, .travelPass, .vehicleRental, .fuel, .otherTransport]
        case .accommodation:
            [.hotel, .accommodationRental, .touristTax, .otherAccomodation]
        case .leisure:
            [.tour, .landmark, .park, .activity, .entertainment, .otherLeisure]
        case .shopping:
            [.clothing, .cosmetics, .souvenirs, .jewelry, .homeGoods, .electronics, .otherShopping]
        case .medicine:
            [.healthInsurance, .medicalCare, .medication, .otherMedicine]
        case .miscellaneous:
            [.connectivity, .bankFees, .documents, .laundry, .donation, .luggageStorage, .postalService, .digitalService, .otherMiscellaneous]
        }
    }
}
