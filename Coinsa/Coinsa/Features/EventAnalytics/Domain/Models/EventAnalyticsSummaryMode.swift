//
//  EventAnalyticsSummaryMode.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 29.04.2026.
//

/// Режим отображения сводной аналитики по событию.
enum EventAnalyticsSummaryMode: String, CaseIterable, Identifiable {
    // MARK: - Значения
    
    case perCategory
    case fromTotal

    // MARK: - Основные свойства
    
    var id: String { rawValue }
}
