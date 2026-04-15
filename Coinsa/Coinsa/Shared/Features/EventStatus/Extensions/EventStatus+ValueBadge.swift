//
//  EventStatus+ValueBadge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

extension EventStatus: ValueBadgeProviding {    
    var badgeColor: Color {
        switch self {
        case .upcoming: .teal
        case .ongoing: .green
        case .completed: .gray
        }
    }
    
    var badgeTitle: LocalizedStringResource? {
        self.localizedResource
    }
}
