//
//  EventStatus+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.03.2026.
//

import Foundation

extension EventStatus: LocalizedResourceProviding {
    /// Локализованное название статуса в единственном числе.
    var localizedResource: LocalizedStringResource {
        switch self {
        case .upcoming: .eventStatusUpcoming
        case .ongoing: .eventStatusOngoing
        case .completed: .eventStatusCompleted
        }
    }
    
    /// Локализованное название статуса во множественном числе.
    var localizedResourcePlural: LocalizedStringResource? {
        switch self {
        case .upcoming: .eventStatusUpcomingPlural
        case .ongoing: .eventStatusOngoingPlural
        case .completed: .eventStatusCompletedPlural
        }
    }
}
