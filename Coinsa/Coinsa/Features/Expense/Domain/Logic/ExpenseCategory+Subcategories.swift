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
                .intercityBus,
                .publicTransport,
                .taxi,
                .transfer,
                .travelPass,
                .vehicleRental,
                .fuel,
                .vehicleMaintenance,
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
                .accommodationServices,
                .otherAccommodation
            ]
        case .leisure:
            [
                .tour,
                .landmark,
                .park,
                .beach,
                .activity,
                .equipmentRental,
                .entertainment,
                .relaxation,
                .otherLeisure
            ]
        case .shopping:
            [
                .clothing,
                .cosmetics,
                .hygiene,
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
                .tips,
                .luggageStorage,
                .postalService,
                .digitalService,
                .otherMiscellaneous
            ]
        }
    }
}
