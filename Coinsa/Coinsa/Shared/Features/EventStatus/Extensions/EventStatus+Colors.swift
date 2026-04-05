//
//  EventStatus+Colors.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

extension EventStatus {
    var badgeColor: Color {
        switch self {
        case .upcoming: .teal
        case .ongoing: .green
        case .completed: .blue
        }
    }
}
