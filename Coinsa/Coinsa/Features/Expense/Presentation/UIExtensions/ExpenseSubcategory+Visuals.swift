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
        case .breakfast: "sun.horizon"
        case .lunch: "sun.max"
        case .dinner: "moon"
        case .snack: "cup.and.saucer"
        case .groceries: "carrot"
        
        case .plane: "airplane"
        case .ferry: "ferry"
        case .train: "tram"
        case .publicTransport: "bus"
        case .taxi: "car"
        case .transfer: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath"
        case .travelPass: "ticket"
        case .vehicleRental: "key"
        case .fuel: "fuelpump"
        
        case .hotel: "bed.double"
        case .accommodationRental: "house"
        case .touristTax: "dollarsign.circle"
        
        case .tour: "map"
        case .landmark: "building.columns"
        case .park: "tree"
        case .activity: "figure.run"
        case .entertainment: "theatermasks"
        
        case .clothing: "tshirt"
        case .cosmetics: "face.smiling"
        case .souvenirs: "gift"
        case .jewelry: "crown"
        case .homeGoods: "lamp.table"
        case .electronics: "headphones"
        
        case .healthInsurance: "staroflife.shield"
        case .medicalCare: "stethoscope"
        case .medication: "pills"
        
        case .connectivity: "wifi"
        case .bankFees: "percent"
        case .documents: "text.document"
        case .laundry: "washer"
        case .donation: "heart"
        case .luggageStorage: "suitcase.rolling"
        case .postalService: "shippingbox"
        case .digitalService: "apple.logo"
        case .other: "circle.grid.cross"
        }
    }
    
    /// Вторичная иконка подкатегории (заливная версия).
    var secondaryIcon: String {
        switch self {
        case .breakfast: "sun.horizon.fill"
        case .lunch: "sun.max.fill"
        case .dinner: "moon.fill"
        case .snack: "cup.and.saucer.fill"
        case .groceries: "carrot.fill"
        
        case .plane: "airplane"
        case .ferry: "ferry.fill"
        case .train: "tram.fill"
        case .publicTransport: "bus.fill"
        case .taxi: "car.fill"
        case .transfer: "point.topright.filled.arrow.triangle.backward.to.point.bottomleft.scurvepath"
        case .travelPass: "ticket.fill"
        case .vehicleRental: "key.fill"
        case .fuel: "fuelpump.fill"
        
        case .hotel: "bed.double.fill"
        case .accommodationRental: "house.fill"
        case .touristTax: "dollarsign.circle.fill"
        
        case .tour: "map.fill"
        case .landmark: "building.columns.fill"
        case .park: "tree.fill"
        case .activity: "figure.run."
        case .entertainment: "theatermasks.fill"
        
        case .clothing: "tshirt.fill"
        case .cosmetics: "face.smiling.fill"
        case .souvenirs: "gift.fill"
        case .jewelry: "crown.fill"
        case .homeGoods: "lamp.table.fill"
        case .electronics: "headphones"
        
        case .healthInsurance: "staroflife.shield.fill"
        case .medicalCare: "stethoscope"
        case .medication: "pills.fill"
        
        case .connectivity: "wifi"
        case .bankFees: "percent"
        case .documents: "text.document.fill"
        case .laundry: "washer.fill"
        case .donation: "heart.fill"
        case .luggageStorage: "suitcase.rolling.fill"
        case .postalService: "shippingbox"
        case .digitalService: "apple.logo"
        case .other: "circle.grid.cross.fill"
        }
    }
    
    /// Акцентный цвет подкатегории.
    var accentColor: Color {
        .black
    }
}
