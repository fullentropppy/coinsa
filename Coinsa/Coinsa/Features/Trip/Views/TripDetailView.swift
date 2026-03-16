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
    @Environment(AppSettingsStore.self) private var settingsStore
    
    @Query private var trips: [Trip]
    @Query private var locations: [Location]

    @State private var viewModel: TripDetailViewModel?
    @State private var deletionHandler = DeletionHandler<Location>(
        messageKey: "location.deletionConfirmation.message.single"
    )
    
    @State private var isShowingTripEdit = false
    @State private var isShowingLocationAdd = false

    let tripID: PersistentIdentifier

    // MARK: - Computed Properties

    private var trip: Trip? {
        trips.first
    }
    
    private var repository: LocationRepository {
        LocationRepository(context: context)
    }
    
    // MARK: - Initialization

    init(tripID: PersistentIdentifier) {
        self.tripID = tripID
        
        _trips = Query(
            filter: #Predicate<Trip> { $0.persistentModelID == tripID }
        )
        
        _locations = Query(
            filter: #Predicate<Location> { $0.trip.persistentModelID == tripID },
            sort: \.startDate
        )
        
        _viewModel = State(initialValue: nil)
    }

    // MARK: - Body

    var body: some View {
        Group {
            if let trip, let viewModel {
                detailContent(trip: trip, viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            updateViewModel()
        }
        .onChange(of: trips.count) { _, _ in
            updateViewModel()
        }
    }

    // MARK: - Components

    private func detailContent(trip: Trip, viewModel: TripDetailViewModel) -> some View {
        List {
            Section {
                TripHeaderView(
                    data: viewModel.headerData,
                    showsSummary: !locations.isEmpty
                )
            }

            Section(header: Text("trip.detail.locations.header")) {
                if locations.isEmpty {
                    emptyLocationListContent
                } else {
                    locationListContent
                }
            }
        }
        .navigationTitle(trip.name)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingTripEdit) {
            TripEditView(trip: trip)
        }
        .sheet(isPresented: $isShowingLocationAdd) {
            LocationEditView(
                trip: trip,
                baseCurrencyOption: viewModel.baseCurrencyOption
            )
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
                ButtonView.add {
                    isShowingLocationAdd = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private var locationListContent: some View {
        ForEach(locations) { location in
            NavigationLink {
                LocationDetailView(locationID: location.persistentModelID)
            } label: {
                LocationRowView(location: location)
            }
        }
        .onDelete(perform: requestDelete)
    }
    
    private var emptyLocationListContent: some View {
        EmptyStateView(
            imageName: "mappin.and.ellipse",
            title: "location.list.empty.title",
            description: "location.list.empty.desctiption",
            buttonLabel: "location.list.addLocation",
            onAddAction: { isShowingLocationAdd = true }
        )
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ButtonView.edit {
                isShowingTripEdit = true
            }
        }
    }

    // MARK: - Actions

    private func updateViewModel() {
        guard let trip else {
            viewModel = nil
            return
        }
        viewModel = TripDetailViewModel(
            trip: trip,
            baseCurrencyOption: settingsStore.baseCurrencyOption
        )
    }
    
    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.requestDelete(items: offsets.map { locations[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirmDelete { repository.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancelDelete()
    }
}

// MARK: - Previews

private extension TripDetailView {
    static func preview(
        withLocations: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder.builder().withLocations(withLocations)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let tripID = builder.fetchTrip(from: container).persistentModelID
        
        return NavigationStack {
            TripDetailView(tripID: tripID)
                .modelContainer(container)
                .environment(settingsStore)
                .environment(\.locale, locale)
                .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    TripDetailView.preview(
        withLocations: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Dark - EN") {
    TripDetailView.preview(
        withLocations: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Empty List. Light - RU") {
    TripDetailView.preview(
        withLocations: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Empty List. Dark - EN") {
    TripDetailView.preview(
        withLocations: false, locale: PreviewLocale.ru.locale, colorScheme: .dark
    )
}
