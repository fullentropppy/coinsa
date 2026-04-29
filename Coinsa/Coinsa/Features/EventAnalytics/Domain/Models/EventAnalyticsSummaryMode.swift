//
//  EventAnalyticsSummaryMode.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

enum EventAnalyticsSummaryMode: String, CaseIterable, Identifiable {
    case perCategory
    case fromTotal

    var id: String { rawValue }
}
