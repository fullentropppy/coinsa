//
//  TripDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

struct TripDetailView: View {
    // MARK: - Stored Properties

    @Environment(\.modelContext) private var context
    @Query private var locations: [Location]

    @State private var isShowingTripEdit = false
    @State private var isShowingLocationAdd = false
    @State private var deletionHandler = DeletionHandler<Location>(
        messageKey: "location.deletionConfirmation.message.single"
    )

    let trip: Trip

    // MARK: - Initialization

    init(trip: Trip) {
        self.trip = trip
        let tripID = trip.persistentModelID

        _locations = Query(
            filter: #Predicate<Location> { $0.trip.persistentModelID == tripID },
            sort: \.startDate
        )
    }

    // MARK: - Computed Properties

    private var store: LocationStore {
        LocationStore(context: context)
    }

    private var viewModel: TripDetailViewModel {
        TripDetailViewModel(trip: trip)
    }

    // MARK: - Body

    var body: some View {
        List {
            Section {
                TripDetailHeaderView(
                    data: viewModel.headerData,
                    showsSummary: !locations.isEmpty
                )
            }

            Section(header: Text("trip.detail.locations.header")) {
                if locations.isEmpty {
                    EmptyStateView(
                        imageName: "mappin.and.ellipse",
                        title: "location.list.empty.title",
                        description: "location.list.empty.desctiption",
                        buttonLabel: "location.list.addLocation",
                        onAddTrip: { isShowingLocationAdd = true }
                    )
                } else {
                    ForEach(locations) { location in
                        NavigationLink {
                            LocationDetailView(location: location)
                        } label: {
                            LocationRowView(location: location)
                        }
                    }
                    .onDelete(perform: requestDelete)
                }
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingTripEdit) {
            TripEditView(trip: trip)
        }
        .sheet(isPresented: $isShowingLocationAdd) {
            LocationEditView()
        }
        .alert("location.list.deletionConfirmation.title", isPresented: $deletionHandler.isShowingDeleteConfirmation) {
            Button("location.list.deletionConfirmation.delete", role: .destructive) {
                confirmDelete()
            }
            Button("common.cancel", role: .cancel) {
                cancelDelete()
            }
        } message: {
            Text(deletionHandler.confirmationMessage)
        }
        .overlay(alignment: .bottomTrailing) {
            if !locations.isEmpty {
                addLocationButton
            }
        }
    }

    // MARK: - Components

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button("trip.detail.editTrip", systemImage: "pencil") {
                isShowingTripEdit = true
            }
        }
    }

    private var addLocationButton: some View {
        Button {
            isShowingLocationAdd = true
        } label: {
            Image(systemName: "plus")
                
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .padding(15)
                .background(Circle().fill(Color.accentColor))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .padding(20)
    }

    // MARK: - Actions

    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.requestDelete(items: offsets.map { locations[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { store.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews

private struct previewData {
    let container: ModelContainer
    let trip: Trip

    init(withLocations: Bool) {
        let builder = PreviewBuilder.builder().withLocations(withLocations)
        self.container = builder.buildContainer()
        self.trip = builder.fetchTrip(from: container)
    }
}

#Preview("Light - RU") {
    let data = previewData(withLocations: true)
    NavigationStack {
        TripDetailView(trip: data.trip)
            .modelContainer(data.container)
            .environment(\.locale, Locale(identifier: "ru"))
            .preferredColorScheme(.light)
    }
}

#Preview("Dark - EN") {
    let data = previewData(withLocations: true)
    NavigationStack {
        TripDetailView(trip: data.trip)
            .modelContainer(data.container)
            .environment(\.locale, Locale(identifier: "en"))
            .preferredColorScheme(.dark)
    }
}

#Preview("Empty list") {
    let data = previewData(withLocations: false)
    NavigationStack {
        TripDetailView(trip: data.trip)
            .modelContainer(data.container)
    }
}
