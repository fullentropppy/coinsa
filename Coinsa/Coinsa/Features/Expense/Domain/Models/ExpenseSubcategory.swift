//
//  ExpenseSubcategory.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 01.06.2026.
//

import SwiftUI

/// Подкатегории трат (универсальные для всех категорий).
enum ExpenseSubcategory: String, Codable, CaseIterable, Identifiable {
    // MARK: - Еда
    
    case breakfast
    case lunch
    case dinner
    case snack
    case groceries
    
    // MARK: - Транспорт
    
    case plane
    case ferry
    case train
    case publicTransport
    case taxi
    case transfer
    case travelPass
    case vehicleRental
    case fuel
    
    // MARK: - Жилье
    
    case hotel
    case accommodationRental
    case touristTax
    
    // MARK: - Досуг
    
    case tour
    case landmark
    case park
    case activity
    case entertainment
    
    // MARK: - Шоппинг
    
    case clothing
    case cosmetics
    case souvenirs
    case jewelry
    case homeGoods
    case electronics
    
    // MARK: - Медицина
    
    case healthInsurance
    case medicalCare
    case medication
    
    // MARK: - Прочее
    
    case connectivity
    case bankFees
    case documents
    case laundry
    case donation
    case luggageStorage
    case postalService
    case digitalService
    case other
    
    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
