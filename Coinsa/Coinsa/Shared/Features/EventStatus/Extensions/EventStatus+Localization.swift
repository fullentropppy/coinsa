//
//  EventStatus+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import SwiftUI

extension EventStatus {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .upcoming: .eventStatusUpcoming
        case .ongoing: .eventStatusOngoing
        case .completed: .eventStatusCompleted
        }
    }
    
    var localizedResourcePlural: LocalizedStringResource {
        switch self {
        case .upcoming: .eventStatusUpcomingPlural
        case .ongoing: .eventStatusOngoingPlural
        case .completed: .eventStatusCompletedPlural
        }
    }
}
