//
//  EventStatus+IconName.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import Foundation

extension EventStatus {
    // MARK: - Computed Properties

    var iconName: String {
        switch self {
        case .upcoming:
            return "clock.circle.fill"
        case .ongoing:
            return "play.circle.fill"
        case .completed:
            return "checkmark.circle.fill"
        }
    }
}
