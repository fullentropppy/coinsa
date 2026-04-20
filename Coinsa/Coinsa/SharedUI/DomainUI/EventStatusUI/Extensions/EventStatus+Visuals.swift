//
//  EventStatus+Visuals.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 20.04.2026.
//

import SwiftUI

extension EventStatus: ValueVisualRepresentable {
    var primaryIcon: String {
        switch self {
        case .upcoming: "clock"
        case .ongoing: "play.circle"
        case .completed: "checkmark.circle"
        }
    }
    
    var secondaryIcon: String {
        switch self {
        case .upcoming: "clock.fill"
        case .ongoing: "play.circle.fill"
        case .completed: "checkmark.circle.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .upcoming: .teal
        case .ongoing: .green
        case .completed: .gray
        }
    }
}
