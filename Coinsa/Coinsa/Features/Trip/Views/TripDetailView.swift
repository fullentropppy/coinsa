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
    @Environment(\.dismiss) private var dismiss
    
    @Query private var locations: [Location]
    
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var isShowingTripEdit = false
    @State private var isShowingLocationCreate = false
    @State private var locationToEdit: Location?

    private let trip: Trip

    // MARK: - Computed Properties
    
    private var repository: LocationRepository {
        LocationRepository(context: context)
    }
    
    private var viewModel: TripDetailViewModel {
        TripDetailViewModel(
            trip: trip,
            baseCurrency: settingsStore.baseCurrency
        )
    }
    
    private var groupedLocations: [(status: EventStatus, locations: [Location])] {
        let grouped = Dictionary(grouping: locations) { $0.status }
        let statusOrder: [EventStatus] = [.ongoing, .upcoming, .completed]
        
        return statusOrder.compactMap { status in
            guard var locationsForStatus = grouped[status] else { return nil }
            
            switch status {
            case .ongoing: locationsForStatus.sort { $0.startDate > $1.startDate }
            case .upcoming: locationsForStatus.sort { $0.startDate < $1.startDate }
            case .completed: locationsForStatus.sort { $0.endDate > $1.endDate }
            }
            
            return (status, locationsForStatus)
        }
    }
    
    private var showsFullHeader: Bool {
        !locations.isEmpty
    }
    
    // MARK: - Initialization

    init(trip: Trip) {
        let tripID = trip.persistentModelID
        _locations = Query(
            filter: #Predicate<Location> { location in
                location.trip.persistentModelID == tripID
            }
        )
        self.trip = trip
    }

    // MARK: - Body

    var body: some View {
        tripDetailForm
            .navigationTitle(trip.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingTripEdit) {
                TripEditView( trip: trip, onDelete: { dismiss() } )
            }
            .sheet(isPresented: $isShowingLocationCreate) {
                LocationEditView( trip: trip, baseCurrency: settingsStore.baseCurrency)
            }
            .sheet(item: $locationToEdit) { location in
                LocationEditView(location: location, baseCurrency: settingsStore.baseCurrency)
            }
            .safeAreaInset(edge: .bottom) {
                if !locations.isEmpty {
                    PrimaryAddButton(isOnLeft: settingsStore.isAddButtonOnLeft) {
                        isShowingLocationCreate = true
                    }
                }
            }
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
                title: .locationDeleteTitle,
                message: .locationDeleteMessage,
                onConfirm: {
                    confirmDelete()
                },
                onCancel: {
                    cancelDelete()
                }
            )
    }

    // MARK: - Content
    
    private var tripDetailForm: some View {
        List {
            headerSection
            locationsSection
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        Section {
            EventSummaryView(
                data: viewModel.eventHeaderData,
                showsAmounts: showsFullHeader,
                showsDifference: showsFullHeader
            )
        }
    }
    
    private var locationsSection: some View {
        Group {
            if locations.isEmpty {
                emptyLocationListContent
            } else {
                locationListContent
            }
        }
    }
    
    // MARK: - Components

    private var emptyLocationListContent: some View {
        EmptyStateView(
            imageName: Location.primaryIcon,
            title: .locationEmptyStateTitle,
            description: .locationEmptyStateDescription,
            buttonLabel: .locationAdd,
        ) {
            isShowingLocationCreate = true
        }
        .listRowBackground(Color.clear)
    }
    
    private var locationListContent: some View {
        Group {
            GroupHeaderView(title: .tripLocations, icon: Location.primaryIcon)
                .listRowBackground(Color.clear)
            
            ForEach(Array(groupedLocations.enumerated()), id: \.offset) { _, group in
                Section(group.status.localizedPlural) {
                    ForEach(group.locations) { location in
                        NavigationLink {
                            LocationDetailView(location: location)
                        } label: {
                            LocationRowView(location: location)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            SwipeActions(
                                onDelete: { requestDelete(for: [location]) },
                                onEdit: { locationToEdit = location }
                            )
                        }
                    }
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            ToolbarButton.edit {
                isShowingTripEdit = true
            }
        }
    }

    // MARK: - Actions
    
    private func requestDelete(for locations: [Location]) {
        deletionHandler.request(for: locations)
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
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withLocations: Bool = true
    ) -> some View {
        let builder = PreviewBuilder.builder().withLocations(withLocations)
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)
        let trip = builder.fetchTrip(from: container)
        
        return NavigationStack {
            TripDetailView(trip: trip)
        }
        .modelContainer(container)
        .environment(settingsStore)
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    TripDetailView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripDetailView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("No Locations. Light - RU") {
    TripDetailView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withLocations: false)
}

#Preview("No Locations. Dark - EN") {
    TripDetailView.makePreview(locale: PreviewLocale.ru, colorScheme: .dark, withLocations: false)
}
