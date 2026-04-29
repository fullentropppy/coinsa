//
//  EventCategoryAnalyticsData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import Foundation

struct EventCategoryAnalyticsData {
    let dateRange: ClosedRange<Date>
    let baseCurrency: Currency
    let localCurrency: Currency?
    let plannedAmountByCategory: [CategoryAnalyticsSlice]
    let actualAmountByCategory: [CategoryAnalyticsSlice]
}
