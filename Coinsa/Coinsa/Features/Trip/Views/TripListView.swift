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
            tripListContent
            .navigationTitle("trip.list.navigationTitle")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingEdtitingSheet) {
                TripEditView(trip: nil)
            }
            .alert("trip.list.deletionConfirmation.title",
                   isPresented: $deletionHandler.isShowingDeleteConfirmation
            ) {
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
                    emptyStateContent
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var tripListContent: some View {
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
    }
    
    private var emptyStateContent: some View {
        EmptyStateView(
            imageName: "suitcase",
            title: "trip.list.empty.title",
            description: "trip.list.empty.desctiption",
            buttonLabel: "trip.list.addTrip",
            onAddAction: { isShowingEdtitingSheet = true }
        )
    }
    
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

private extension TripListView {
    static func preview(
        withTrips: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let container = PreviewBuilder.builder()
            .withScenario(.all)
            .withTrips(withTrips)
            .withExpenses(false)
            .withBudgets(false)
            .buildContainer()

        return TripListView()
            .modelContainer(container)
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

#Preview("Empty list. Light - RU") {
    TripListView.preview(
        withTrips: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Empty list. Dark - EN") {
    TripListView.preview(
        withTrips: false, locale: PreviewLocale.ru.locale, colorScheme: .dark
    )
}
