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
    @State private var deletionHandler = DeletionHandler<Location>()
    
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

            Section(header: Text("trip.locations")) {
                if locations.isEmpty {
                    emptyLocationListContent
                } else {
                    locationListContent
                }
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingTripEdit) {
            TripEditView(trip: trip)
        }
        .sheet(isPresented: $isShowingLocationAdd) {
            LocationEditView(
                trip: trip,
                baseCurrency: viewModel.baseCurrency
            )
        }
        .overlay(alignment: .bottomTrailing) {
            if !locations.isEmpty {
                ButtonView.add {
                    isShowingLocationAdd = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .deleteConfirmationAlert(
            isPresented: $deletionHandler.isShowingDeleteConfirmation,
            message: "location.delete.message",
            onConfirm: {
                confirmDelete()
            },
            onCancel: {
                cancelDelete()
            }
        )
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
            title: "location.emptyState.title",
            description: "location.emptyState.description",
            buttonLabel: "location.add",
            onAddAction: { isShowingLocationAdd = true }
        )
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            ContextToolbarTitleView(title: trip!.name)
        }
        
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
            baseCurrency: settingsStore.baseCurrency
        )
    }
    
    private func requestDelete(at offsets: IndexSet) {
        deletionHandler.request(for: offsets.map { locations[$0] })
    }

    private func confirmDelete() {
        deletionHandler.confirm { repository.delete($0) }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
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
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
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
