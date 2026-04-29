//
//  EventAnalyticsSummaryMode+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

import SwiftUI

extension EventAnalyticsSummaryMode: LocalizedResourceProviding {
    var localizedResource: LocalizedStringResource {
        switch self {
        case .perCategory: .analyticsSummaryPerCategory
        case .fromTotal: .analyticsSummaryFromTotal
        }
    }
}
