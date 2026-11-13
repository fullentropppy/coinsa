//
//  ExpenseMapPreviewData.swift
//  Coinsa
//

import Foundation
import SwiftData

/// Синтетические данные карты в памяти без CloudKit и с отдельными настройками.
struct ExpenseMapPreviewData {
    let container: ModelContainer
    let analyticsData: EventCategoryAnalyticsData
    let screenContextSubtitle: String
    let settingsStore: AppSettingsStore

    var expenses: [Expense] {
        analyticsData.expenses
    }

    /// Создает синтетические данные карты во временном in-memory хранилище без CloudKit.
    init(forTrip: Bool = false, includeExpenses: Bool = true) {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container: ModelContainer

        do {
            container = try ModelContainer(
                for: Trip.self, Location.self, Expense.self,
                configurations: configuration
            )

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

        guard let defaults = UserDefaults(suiteName: "Coinsa.ExpenseMapPreview.\(UUID().uuidString)") else {
            fatalError("Failed to create expense map preview settings")
        }

        self.container = container
        settingsStore = AppSettingsStore(defaults: defaults)
        settingsStore.fetchExpenseExchangeRateOnline = false
        settingsStore.detectPlaceOfExpense = false
    }
}
