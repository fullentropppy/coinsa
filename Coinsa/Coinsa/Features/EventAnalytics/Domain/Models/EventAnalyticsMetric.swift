//
//  EventAnalyticsMetric.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

enum EventAnalyticsMetric: String, CaseIterable, Identifiable {
    case summary
    case plan
    case actual

    var id: String { rawValue }
}
