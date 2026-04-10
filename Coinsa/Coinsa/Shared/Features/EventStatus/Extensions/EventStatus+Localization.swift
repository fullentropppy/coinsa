//
//  EventStatus+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import SwiftUI

extension EventStatus {
    var localized: LocalizedStringResource {
        switch self {
        case .upcoming: .eventStatusUpcoming
        case .ongoing: .eventStatusOngoing
        case .completed: .eventStatusCompleted
        }
    }
    
    var localizedPlural: LocalizedStringResource {
        switch self {
        case .upcoming: .eventStatusUpcomingPlural
        case .ongoing: .eventStatusOngoingPlural
        case .completed: .eventStatusCompletedPlural
        }
    }
}
