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
    @Environment(AppSettingsStore.self) private var settingsStore
    @Query(sort: \Trip.startDate) private var trips: [Trip]

    @State private var isShowingEdtitingSheet = false
    @State private var deletionHandler = DeletionHandler<Trip>(
        messageKey: "trip.deletionConfirmation.message.single"
    )

    // MARK: - Computed Properties
    
    private var store: TripStore {
        TripStore(context: context)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(trips) { trip in
                    NavigationLink {
                        TripDetailView(trip: trip)
                    } label: {
                        TripRowView(trip: trip)
                    }
                }
                .onDelete(perform: requestDelete)
            }
            .navigationTitle("trip.list.navigationTitle")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingEdtitingSheet) {
                TripEditView(trip: nil, baseCurrencyCode: settingsStore.baseCurrencyCode)
            }
            .alert("trip.list.deletionConfirmation.title", isPresented: $deletionHandler.isShowingDeleteConfirmation) {
                Button("trip.list.deletionConfirmation.delete", role: .destructive) {
                    confirmDelete()
                }
                Button("common.cancel", role: .cancel) {
                    cancelDelete()
                }
            } message: {
                Text(deletionHandler.confirmationMessage)
            }
            .toolbar {
                toolbarContent
            }
            .overlay {
                if trips.isEmpty {
                    EmptyStateView(
                        imageName: "suitcase",
                        title: "trip.list.empty.title",
                        description: "trip.list.empty.desctiption",
                        buttonLabel: "trip.list.addTrip",
                        onAddAction: { isShowingEdtitingSheet = true }
                    )
                }
            }
        }
    }
    
    // MARK: - Components
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ButtonView.add {
                isShowingEdtitingSheet = true
            }
        }
    }
    
    // MARK: - Actions

    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.requestDelete(items: offsets.map { trips[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { store.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews

private struct PreviewData {
    let container: ModelContainer

    init(withTrips: Bool) {
        self.container = PreviewBuilder.builder()
            .withScenario(.all)
            .withTrips(withTrips)
            .withExpenses(false)
            .withBudgets(false)
            .buildContainer()
    }
}

#Preview("Light - RU") {
    let data = PreviewData(withTrips: true)
    let store = AppSettingsStore(context: data.container.mainContext)
    store.baseCurrencyCode = PreviewCurrency.baseCurrencyCode

    return TripListView()
        .modelContainer(data.container)
        .environment(store)
        .environment(\.locale, Locale(identifier: "ru"))
        .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    let data = PreviewData(withTrips: true)
    let store = AppSettingsStore(context: data.container.mainContext)
    store.baseCurrencyCode = PreviewCurrency.baseCurrencyCode

    return TripListView()
        .modelContainer(data.container)
        .environment(store)
        .environment(\.locale, Locale(identifier: "en"))
        .preferredColorScheme(.dark)
}

#Preview("Empty list") {
    let data = PreviewData(withTrips: false)
    let store = AppSettingsStore(context: data.container.mainContext)
    store.baseCurrencyCode = PreviewCurrency.baseCurrencyCode

    return TripListView()
        .modelContainer(data.container)
        .environment(store)
}
