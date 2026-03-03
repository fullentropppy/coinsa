//
//  EventStatus+Colors.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

extension EventStatus {
    // MARK: - Computed Properties

    var color: Color {
        switch self {
        case .upcoming:
            return .blue
        case .ongoing:
            return .green
        case .completed:
            return .gray
        }
    }
}
