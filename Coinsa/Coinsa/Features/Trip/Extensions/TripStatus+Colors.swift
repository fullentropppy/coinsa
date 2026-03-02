//
//  TripStatus+Colors.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 02.03.2026.
//

import SwiftUI

extension TripStatus {
    // MARK: - Computed properties
    
    var color: Color {
        switch self {
        case .upcoming: return .blue
        case .ongoing: return .green
        case .completed: return .gray
        }
    }
}
