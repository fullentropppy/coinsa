//
//  EventAnalyticsMetric.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

/// Метрика аналитики.
enum EventAnalyticsMetric: String, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case summary
    case days
    case categories

    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
