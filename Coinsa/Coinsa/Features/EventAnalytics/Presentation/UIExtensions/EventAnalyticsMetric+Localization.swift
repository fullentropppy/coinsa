//
//  EventAnalyticsMetric+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

import SwiftUI

extension EventAnalyticsMetric: LocalizedResourceProviding {
    /// Локализованное название метрики аналитики.
    var localizedResource: LocalizedStringResource {
        switch self {
        case .summary: .analyticsSummary
        case .plan: .analyticsPlan
        case .actual: .analyticsActual
        }
    }
}
