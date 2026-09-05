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
            
        case .breakfast: "sun.horizon"
        case .lunch: "sun.max"
        case .dinner: "moon"
        case .snack: "cup.and.saucer"
        case .groceries: "carrot"
        case .otherFood: category.primaryIcon
            
        // MARK: - Транспорт
            
        case .plane: "airplane"
        case .ferry: "ferry"
        case .train: "tram"
        case .publicTransport: "bus"
        case .taxi: "car"
        case .transfer: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath"
        case .travelPass: "ticket"
        case .vehicleRental: "key"
        case .fuel: "fuelpump"
        case .otherTransport: category.primaryIcon
            
        // MARK: - Жилье
            
        case .hotel: "bed.double"
        case .accommodationRental: "key"
        case .touristTax: "dollarsign.circle"
        case .otherAccomodation: category.primaryIcon
            
        // MARK: - Досуг
            
        case .tour: "map"
        case .landmark: "building.columns"
        case .park: "tree"
        case .activity: "figure.run"
        case .entertainment: "theatermasks"
        case .otherLeisure: category.primaryIcon
        
        // MARK: - Шоппинг
            
        case .clothing: "tshirt"
        case .cosmetics: "face.smiling"
        case .souvenirs: "gift"
        case .jewelry: "crown"
        case .homeGoods: "lamp.table"
        case .electronics: "headphones"
        case .otherShopping: category.primaryIcon
            
        // MARK: - Медицина
            
        case .healthInsurance: "staroflife.shield"
        case .medicalCare: "stethoscope"
        case .medication: "pills"
        case .otherMedicine: category.primaryIcon
        
        // MARK: - Прочее
            
        case .connectivity: "wifi"
        case .bankFees: "percent"
        case .documents: "text.document"
        case .laundry: "washer"
        case .donation: "heart"
        case .luggageStorage: "suitcase.rolling"
        case .postalService: "shippingbox"
        case .digitalService: "apple.logo"
        case .otherMiscellaneous: category.primaryIcon
            
        }
    }
    
    /// Вторичная иконка подкатегории (заливная версия).
    var secondaryIcon: String {
        switch self {
            
        // MARK: - Еда
            
        case .breakfast: "sun.horizon.fill"
        case .lunch: "sun.max.fill"
        case .dinner: "moon.fill"
        case .snack: "cup.and.saucer.fill"
        case .groceries: "carrot.fill"
        case .otherFood: category.secondaryIcon
            
        // MARK: - Транспорт
            
        case .plane: "airplane"
        case .ferry: "ferry.fill"
        case .train: "tram.fill"
        case .publicTransport: "bus.fill"
        case .taxi: "car.fill"
        case .transfer: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath"
        case .travelPass: "ticket.fill"
        case .vehicleRental: "key.fill"
        case .fuel: "fuelpump.fill"
        case .otherTransport: category.secondaryIcon
            
        // MARK: - Жилье
            
        case .hotel: "bed.double.fill"
        case .accommodationRental: "key.fill"
        case .touristTax: "dollarsign.circle.fill"
        case .otherAccomodation: category.secondaryIcon
            
        // MARK: - Досуг
            
        case .tour: "map.fill"
        case .landmark: "building.columns.fill"
        case .park: "tree.fill"
        case .activity: "figure.run"
        case .entertainment: "theatermasks.fill"
        case .otherLeisure: category.secondaryIcon
            
        // MARK: - Шоппинг
            
        case .clothing: "tshirt.fill"
        case .cosmetics: "face.smiling.fill"
        case .souvenirs: "gift.fill"
        case .jewelry: "crown.fill"
        case .homeGoods: "lamp.table.fill"
        case .electronics: "headphones"
        case .otherShopping: category.secondaryIcon
            
        // MARK: - Медицина
            
        case .healthInsurance: "staroflife.shield.fill"
        case .medicalCare: "stethoscope"
        case .medication: "pills.fill"
        case .otherMedicine: category.secondaryIcon
            
        // MARK: - Прочее
            
        case .connectivity: "wifi"
        case .bankFees: "percent"
        case .documents: "text.document.fill"
        case .laundry: "washer.fill"
        case .donation: "heart.fill"
        case .luggageStorage: "suitcase.rolling.fill"
        case .postalService: "shippingbox.fill"
        case .digitalService: "apple.logo"
        case .otherMiscellaneous: category.secondaryIcon
        }
    }
    
    /// Акцентный цвет подкатегории.
    var accentColor: Color {
        category.accentColor
    }
}
