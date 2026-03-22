//
//  TripListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI
import SwiftData

struct TripListView: View {
    // MARK: - Stored Properties
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    @State private var isShowingTripEdit = false
    @State private var deletionHandler = DeletionHandler<Trip>()

    // MARK: - Computed Properties
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            tripListContent
                .toolbarTitleDisplayMode(.inline)
                .sheet(isPresented: $isShowingTripEdit) {
                    TripEditView(trip: nil)
                }
                .toolbar {
                    toolbarContent
                }
                .overlay {
                    if trips.isEmpty {
                        emptyTripListContent
                    }
                }
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    message: "trip.delete.message",
                    onConfirm: {
                        confirmDelete()
                    },
                    onCancel: {
                        cancelDelete()
                    }
                )
        }
    }
    
    // MARK: - Components
    
    private var tripListContent: some View {
        List {
            ForEach(trips) { trip in
                NavigationLink {
                    TripDetailView(tripID: trip.persistentModelID)
                } label: {
                    TripRowView(trip: trip)
                }
            }
            .onDelete(perform: requestDelete)
        }
    }
    
    private var emptyTripListContent: some View {
        EmptyStateView(
            imageName: "suitcase",
            title: "trip.list.empty.title",
            description: "trip.list.empty.desctiption",
            buttonLabel: "trip.list.addTrip",
            onAddAction: { isShowingTripEdit = true }
        )
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ContextToolbarTitleView(title: String(localized: "trip.list.navigationTitle"))
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            ButtonView.add {
                isShowingTripEdit = true
            }
        }
    }
    
    // MARK: - Actions

    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.request(for: offsets.map { trips[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Previews

private extension TripListView {
    static func preview(
        withTrips: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let container = PreviewBuilder.builder()
            .withScenario(.all)
            .withTrips(withTrips)
            .withExpenses(true)
            .withBudgets(true)
            .buildContainer()
        
        let settingsStore = AppSettingsStore(context: container.mainContext)
        
        return TripListView()
            .modelContainer(container)
            .environment(settingsStore)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    TripListView.preview(
        withTrips: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Dark - EN") {
    TripListView.preview(
        withTrips: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Empty List. Light - RU") {
    TripListView.preview(
        withTrips: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Empty List. Dark - EN") {
    TripListView.preview(
        withTrips: false, locale: PreviewLocale.ru.locale, colorScheme: .dark
    )
}
