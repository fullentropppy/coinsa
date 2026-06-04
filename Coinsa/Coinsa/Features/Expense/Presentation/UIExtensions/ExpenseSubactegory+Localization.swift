//
//  ExpenseSubactegory+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.06.2026.
//

import Foundation

extension ExpenseSubcategory: LocalizedResourceProviding {
    /// Локализованное название категории траты.
    var localizedResource: LocalizedStringResource {
        switch self {
        case .breakfast: .expenseSubcategoryBreakfast
        case .lunch: .expenseSubcategoryLunch
        case .dinner: .expenseSubcategoryDinner
        case .snack: .expenseSubcategorySnack
        case .groceries: .expenseSubcategoryGroceries
        
        case .plane: .expenseSubcategoryPlane
        case .ferry: .expenseSubcategoryFerry
        case .train: .expenseSubcategoryTrain
        case .publicTransport: .expenseSubcategoryPublicTransport
        case .taxi: .expenseSubcategoryTaxi
        case .transfer: .expenseSubcategoryTransfer
        case .travelPass: .expenseSubcategoryTravelPass
        case .transportRental: .expenseSubcategoryTransportRental
        case .fuel: .expenseSubcategoryFuel
        
        case .hotel: .expenseSubcategoryHotel
        case .accommodationRental: .expenseCategoryAccomodation
        case .touristTax: .expenseSubcategoryTouristTax
        
        case .tour: .expenseSubcategoryTour
        case .landmark: .expenseSubcategoryLandmark
        case .park: .expenseSubcategoryPark
        case .activity: .expenseSubcategoryActivity // ПОМЕНЯТЬ
        case .entertainment: .expenseCategoryEntertainment
        
        case .clothing: .expenseSubcategoryClothing
        case .cosmetics: .expenseSubcategoryCosmetics
        case .souvenirs: .expenseSubcategorySouvenirs
        case .jewelry: .expenseSubcategoryJewelry
        case .homeGoods: .expenseSubcategoryHomeGoods
        case .electronics: .expenseSubcategoryElectronics
        
        case .healthInsurance: .expenseSubcategoryHealthInsurance
        case .medicalCare: .expenseSubcategoryMedicalCare
        case .medication: .expenseSubcategoryMedication
        
        case .connectivity: .expenseSubcategoryConnectivity
        case .bankFee: .expenseSubcategoryBankFee
        case .document: .expenseSubcategoryDocument
        case .laundry: .expenseSubcategoryLaundry
        case .donation: .expenseSubcategoryDonation
        case .luggageStorage: .expenseSubcategoryLuggageStorrage
        case .postalService: .expenseSubcategoryPostalService
        case .digitalService: .expenseSubcategoryDigitalService
        case .other: .expenseSubcategoryOther
        }
    }
}
