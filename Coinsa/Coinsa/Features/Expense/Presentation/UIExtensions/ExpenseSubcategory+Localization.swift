//
//  ExpenseSubcategory+Localization.swift
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
        case .drinks: .expenseSubcategoryDrinks
        case .groceries: .expenseSubcategoryGroceries
        case .otherFood: .expenseSubcategoryOther
            
        // MARK: - Транспорт
            
        case .plane: .expenseSubcategoryPlane
        case .ferry: .expenseSubcategoryFerry
        case .train: .expenseSubcategoryTrain
        case .intercityBus: .expenseSubcategoryIntercityBus
        case .publicTransport: .expenseSubcategoryPublicTransport
        case .taxi: .expenseSubcategoryTaxi
        case .transfer: .expenseSubcategoryTransfer
        case .travelPass: .expenseSubcategoryTravelPass
        case .vehicleRental: .expenseSubcategoryVehicleRental
        case .fuel: .expenseSubcategoryFuel
        case .vehicleMaintenance: .expenseSubcategoryVehicleMaintenance
        case .parking: .expenseSubcategoryParking
        case .tolls: .expenseSubcategoryTolls
        case .baggage: .expenseSubcategoryBaggage
        case .otherTransport: .expenseSubcategoryOther
            
        // MARK: - Жилье
            
        case .hotel: .expenseSubcategoryHotel
        case .accommodationRental: .expenseSubcategoryAccommodationRental
        case .camping: .expenseSubcategoryCamping
        case .touristTax: .expenseSubcategoryTouristTax
        case .accommodationServices: .expenseSubcategoryAccommodationServices
        case .otherAccommodation: .expenseSubcategoryOther
            
        // MARK: - Досуг
            
        case .tour: .expenseSubcategoryTour
        case .landmark: .expenseSubcategoryLandmark
        case .park: .expenseSubcategoryPark
        case .beach: .expenseSubcategoryBeach
        case .activity: .expenseSubcategoryActivity
        case .equipmentRental: .expenseSubcategoryEquipmentRental
        case .entertainment: .expenseSubcategoryEntertainment
        case .relaxation: .expenseSubcategoryRelaxation
        case .otherLeisure: .expenseSubcategoryOther
            
        // MARK: - Шоппинг
            
        case .clothing: .expenseSubcategoryClothing
        case .cosmetics: .expenseSubcategoryCosmetics
        case .hygiene: .expenseSubcategoryHygiene
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
        case .personalCare: .expenseSubcategoryPersonalCare
        case .donation: .expenseSubcategoryDonation
        case .tips: .expenseSubcategoryTips
        case .luggageStorage: .expenseSubcategoryLuggageStorage
        case .postalService: .expenseSubcategoryPostalService
        case .digitalService: .expenseSubcategoryDigitalService
        case .otherMiscellaneous: .expenseSubcategoryOther
        }
    }
}
