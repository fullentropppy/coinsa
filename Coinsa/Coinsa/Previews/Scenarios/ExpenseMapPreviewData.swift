//
//  ExpenseMapPreviewData.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import SwiftData

/// Синтетические данные карты в памяти без CloudKit и с отдельными настройками.
@MainActor
struct ExpenseMapPreviewData {
    let container: ModelContainer
    let analyticsData: EventCategoryAnalyticsData
    let screenContextSubtitle: String
    let settingsStore: AppSettingsStore

    var expenses: [Expense] {
        analyticsData.expenses
    }

    /// Создает синтетические данные карты во временном in-memory хранилище без CloudKit.
    /// - Parameters:
    ///   - forTrip: Подготавливать аналитику всей поездки или отдельной локации.
    ///   - includeExpenses: Добавлять примеры трат или оставить карту пустой.
    init(forTrip: Bool = false, includeExpenses: Bool = true) {
        let environment = PreviewEnvironment()
        container = environment.container
        settingsStore = environment.settingsStore

        do {
            if forTrip {
                let trip = PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: includeExpenses)
                container.mainContext.insert(trip)
                analyticsData = TripDetailViewModel(trip: trip).eventAnalyticsData
                screenContextSubtitle = trip.screenContextSubtitle
            } else {
                let location = PreviewGenerator.makeExampleLocation(includeExpenses: includeExpenses)
                container.mainContext.insert(location)
                analyticsData = LocationDetailViewModel(location: location).eventAnalyticsData
                screenContextSubtitle = location.screenContextSubtitle
            }

            try container.mainContext.save()
        } catch {
            fatalError("Failed to create expense map preview data: \(error)")
        }
    }
}
