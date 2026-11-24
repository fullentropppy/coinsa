//
//  ExpenseSubcategory+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.06.2026.
//

import SwiftUI

extension ExpenseSubcategory: ValueVisualRepresentable {
    /// Основная иконка подкатегории (контурная версия).
    var primaryIcon: String {
        switch self {
        
        // MARK: - Еда
            
        case .breakfast: AppSymbols.sunHorizon
        case .lunch: AppSymbols.sunMax
        case .dinner: AppSymbols.moon
        case .snack: AppSymbols.pizzaSlice
        case .drinks: AppSymbols.mug
        case .groceries: AppSymbols.carrot
        case .otherFood: category.primaryIcon
            
        // MARK: - Транспорт
            
        case .plane: AppSymbols.airplane
        case .ferry: AppSymbols.ferry
        case .train: AppSymbols.tram
        case .intercityBus: AppSymbols.busDoubledecker
        case .publicTransport: AppSymbols.bus
        case .taxi: AppSymbols.figureWave
        case .transfer: AppSymbols.pointToprightFilledArrowTriangleBackwardToPointBottomleftScurvepath
        case .travelPass: AppSymbols.ticket
        case .vehicleRental: AppSymbols.key
        case .fuel: AppSymbols.fuelpump
        case .vehicleMaintenance: AppSymbols.wrenchAndScrewdriver
        case .parking: AppSymbols.parkingsignSquare
        case .tolls: AppSymbols.roadLanes
        case .baggage: AppSymbols.suitcase
        case .otherTransport: category.primaryIcon
            
        // MARK: - Жилье
            
        case .hotel: AppSymbols.bedDouble
        case .accommodationRental: AppSymbols.key
        case .camping: AppSymbols.tent
        case .touristTax: AppSymbols.dollarsignCircle
        case .accommodationServices: AppSymbols.bell
        case .otherAccommodation: category.primaryIcon
            
        // MARK: - Досуг
            
        case .tour: AppSymbols.map
        case .landmark: AppSymbols.buildingColumns
        case .park: AppSymbols.tree
        case .beach: AppSymbols.beachUmbrella
        case .activity: AppSymbols.figureRun
        case .equipmentRental: AppSymbols.basketball
        case .entertainment: AppSymbols.theatermasks
        case .relaxation: AppSymbols.leaf
        case .otherLeisure: category.primaryIcon
        
        // MARK: - Шоппинг
            
        case .clothing: AppSymbols.tshirt
        case .cosmetics: AppSymbols.faceSmiling
        case .hygiene: AppSymbols.bubblesAndSparkles
        case .souvenirs: AppSymbols.gift
        case .jewelry: AppSymbols.crown
        case .homeGoods: AppSymbols.lampTable
        case .electronics: AppSymbols.headphones
        case .otherShopping: category.primaryIcon
            
        // MARK: - Медицина
            
        case .healthInsurance: AppSymbols.staroflifeShield
        case .medicalCare: AppSymbols.stethoscope
        case .medication: AppSymbols.pills
        case .otherMedicine: category.primaryIcon
        
        // MARK: - Прочее
            
        case .connectivity: AppSymbols.wifi
        case .bankFees: AppSymbols.percent
        case .documents: AppSymbols.textDocument
        case .laundry: AppSymbols.washer
        case .personalCare: AppSymbols.comb
        case .donation: AppSymbols.heart
        case .tips: AppSymbols.banknote
        case .luggageStorage: AppSymbols.suitcaseRolling
        case .postalService: AppSymbols.shippingbox
        case .digitalService: AppSymbols.appleLogo
        case .otherMiscellaneous: category.primaryIcon
            
        }
    }
    
    /// Вторичная иконка подкатегории (заливная версия).
    var secondaryIcon: String {
        switch self {
            
        // MARK: - Еда
            
        case .breakfast: AppSymbols.sunHorizonFill
        case .lunch: AppSymbols.sunMaxFill
        case .dinner: AppSymbols.moonFill
        case .snack: AppSymbols.pizzaSliceFill
        case .drinks: AppSymbols.mugFill
        case .groceries: AppSymbols.carrotFill
        case .otherFood: category.secondaryIcon
            
        // MARK: - Транспорт
            
        case .plane: AppSymbols.airplane
        case .ferry: AppSymbols.ferryFill
        case .train: AppSymbols.tramFill
        case .intercityBus: AppSymbols.busDoubledeckerFill
        case .publicTransport: AppSymbols.busFill
        case .taxi: AppSymbols.figureWave
        case .transfer: AppSymbols.pointToprightFilledArrowTriangleBackwardToPointBottomleftScurvepath
        case .travelPass: AppSymbols.ticketFill
        case .vehicleRental: AppSymbols.keyFill
        case .fuel: AppSymbols.fuelpumpFill
        case .vehicleMaintenance: AppSymbols.wrenchAndScrewdriverFill
        case .parking: AppSymbols.parkingsignSquareFill
        case .tolls: AppSymbols.roadLanes
        case .baggage: AppSymbols.suitcaseFill
        case .otherTransport: category.secondaryIcon
            
        // MARK: - Жилье
            
        case .hotel: AppSymbols.bedDoubleFill
        case .accommodationRental: AppSymbols.keyFill
        case .camping: AppSymbols.tentFill
        case .touristTax: AppSymbols.dollarsignCircleFill
        case .accommodationServices: AppSymbols.bellFill
        case .otherAccommodation: category.secondaryIcon
            
        // MARK: - Досуг
            
        case .tour: AppSymbols.mapFill
        case .landmark: AppSymbols.buildingColumnsFill
        case .park: AppSymbols.treeFill
        case .beach: AppSymbols.beachUmbrellaFill
        case .activity: AppSymbols.figureRun
        case .equipmentRental: AppSymbols.basketballFill
        case .entertainment: AppSymbols.theatermasksFill
        case .relaxation: AppSymbols.leafFill
        case .otherLeisure: category.secondaryIcon
            
        // MARK: - Шоппинг
            
        case .clothing: AppSymbols.tshirtFill
        case .cosmetics: AppSymbols.faceSmilingFill
        case .hygiene: AppSymbols.bubblesAndSparkles
        case .souvenirs: AppSymbols.giftFill
        case .jewelry: AppSymbols.crownFill
        case .homeGoods: AppSymbols.lampTableFill
        case .electronics: AppSymbols.headphones
        case .otherShopping: category.secondaryIcon
            
        // MARK: - Медицина
            
        case .healthInsurance: AppSymbols.staroflifeShieldFill
        case .medicalCare: AppSymbols.stethoscope
        case .medication: AppSymbols.pillsFill
        case .otherMedicine: category.secondaryIcon
            
        // MARK: - Прочее
            
        case .connectivity: AppSymbols.wifi
        case .bankFees: AppSymbols.percent
        case .documents: AppSymbols.textDocumentFill
        case .laundry: AppSymbols.washerFill
        case .personalCare: AppSymbols.combFill
        case .donation: AppSymbols.heartFill
        case .tips: AppSymbols.banknoteFill
        case .luggageStorage: AppSymbols.suitcaseRollingFill
        case .postalService: AppSymbols.shippingboxFill
        case .digitalService: AppSymbols.appleLogo
        case .otherMiscellaneous: category.secondaryIcon
        }
    }
    
    /// Акцентный цвет подкатегории.
    var accentColor: Color {
        category.accentColor
    }
}
