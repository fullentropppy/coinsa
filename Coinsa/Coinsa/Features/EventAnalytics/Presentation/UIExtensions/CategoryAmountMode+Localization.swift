//
//  CategoryAmountMode+Localization.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 04.08.2026.
//

import Foundation

extension CategoryAmountMode: LocalizedResourceProviding {
    /// Локализованное название режима отображения трат по категориям.
    var localizedResource: LocalizedStringResource {
        switch self {
        case .total: .analyticsCategoryAmountTotal
        case .daily: .analyticsCategoryAmountDaily
        }
    }
}
