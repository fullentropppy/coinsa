//
//  PaymentMethod.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import Foundation

enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    // MARK: - Cases
    
    case cash
    case card
    
    // MARK: - Computed Properties
    
    var id: String { rawValue }
}
