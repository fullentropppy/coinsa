//
//  ExpenseCategory+Subcategories.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

extension ExpenseCategory {
    // MARK: - Свойства

    /// Дочерние подкатегории для категории.
    nonisolated var subcategories: [ExpenseSubcategory] {
        switch self {
        case .food:
            [
                .breakfast,
                .lunch,
                .dinner,
                .snack,
                .drinks,
                .groceries,
                .otherFood
            ]
        case .transport:
            [
                .plane,
                .ferry,
                .train,
                .publicTransport,
                .taxi,
                .transfer,
                .travelPass,
                .vehicleRental,
                .fuel,
                .parking,
                .tolls,
                .baggage,
                .otherTransport
            ]
        case .accommodation:
            [
                .hotel,
                .accommodationRental,
                .camping,
                .touristTax,
                .otherAccommodation
            ]
        case .leisure:
            [
                .tour,
                .landmark,
                .park,
                .beach,
                .activity,
                .entertainment,
                .relaxation,
                .otherLeisure
            ]
        case .shopping:
            [
                .clothing,
                .cosmetics,
                .souvenirs,
                .jewelry,
                .homeGoods,
                .electronics,
                .otherShopping
            ]
        case .medicine:
            [
                .healthInsurance,
                .medicalCare,
                .medication,
                .otherMedicine
            ]
        case .miscellaneous:
            [
                .connectivity,
                .bankFees,
                .documents,
                .laundry,
                .personalCare,
                .donation,
                .luggageStorage,
                .postalService,
                .digitalService,
                .otherMiscellaneous
            ]
        }
    }
}
