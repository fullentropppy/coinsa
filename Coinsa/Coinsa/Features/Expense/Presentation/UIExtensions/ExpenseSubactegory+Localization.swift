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
        
        // MARK: - Еда
            
        case .breakfast: .expenseSubcategoryBreakfast
        case .lunch: .expenseSubcategoryLunch
        case .dinner: .expenseSubcategoryDinner
        case .snack: .expenseSubcategorySnack
        case .groceries: .expenseSubcategoryGroceries
        case .otherFood: .expenseSubcategoryOther
            
        // MARK: - Транспорт
            
        case .plane: .expenseSubcategoryPlane
        case .ferry: .expenseSubcategoryFerry
        case .train: .expenseSubcategoryTrain
        case .publicTransport: .expenseSubcategoryPublicTransport
        case .taxi: .expenseSubcategoryTaxi
        case .transfer: .expenseSubcategoryTransfer
        case .travelPass: .expenseSubcategoryTravelPass
        case .vehicleRental: .expenseSubcategoryVehicleRental
        case .fuel: .expenseSubcategoryFuel
        case .otherTransport: .expenseSubcategoryOther
            
        // MARK: - Жилье
            
        case .hotel: .expenseSubcategoryHotel
        case .accommodationRental: .expenseSubcategoryAccomodationRental
        case .touristTax: .expenseSubcategoryTouristTax
        case .otherAccomodation: .expenseSubcategoryOther
            
        // MARK: - Досуг
            
        case .tour: .expenseSubcategoryTour
        case .landmark: .expenseSubcategoryLandmark
        case .park: .expenseSubcategoryPark
        case .activity: .expenseSubcategoryActivity // ПОМЕНЯТЬ
        case .entertainment: .expenseCategoryEntertainment
        case .otherLeisure: .expenseSubcategoryOther
            
        // MARK: - Шоппинг
            
        case .clothing: .expenseSubcategoryClothing
        case .cosmetics: .expenseSubcategoryCosmetics
        case .souvenirs: .expenseSubcategorySouvenirs
        case .jewelry: .expenseSubcategoryJewelry
        case .homeGoods: .expenseSubcategoryHomeGoods
        case .electronics: .expenseSubcategoryElectronics
        case .otherShopping: .expenseSubcategoryOther
            
        // MARK: - Медицина
            
        case .healthInsurance: .expenseSubcategoryHealthInsurance
        case .medicalCare: .expenseSubcategoryMedicalCare
        case .medication: .expenseSubcategoryMedication
        case .otherMedicine: .expenseSubcategoryOther
            
        // MARK: - Прочее
            
        case .connectivity: .expenseSubcategoryConnectivity
        case .bankFees: .expenseSubcategoryBankFees
        case .documents: .expenseSubcategoryDocuments
        case .laundry: .expenseSubcategoryLaundry
        case .donation: .expenseSubcategoryDonation
        case .luggageStorage: .expenseSubcategoryLuggageStorrage
        case .postalService: .expenseSubcategoryPostalService
        case .digitalService: .expenseSubcategoryDigitalService
        case .otherMiscellaneous: .expenseSubcategoryOther
        }
    }
}
