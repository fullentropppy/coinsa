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
    @State private var isShowingLocationAdd = false

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
    
    private var showsFullHeader: Bool {
        !locations.isEmpty
    }
    
    // MARK: - Initialization

    init(trip: Trip) {
        let tripID = trip.persistentModelID
        _locations = Query(
            filter: #Predicate<Location> { location in
                location.trip.persistentModelID == tripID
            },
            sort: \Location.startDate
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
                TripEditView(
                    trip: trip,
                    onDelete: {
                        dismiss()
                    }
                )
            }
            .sheet(isPresented: $isShowingLocationAdd) {
                LocationEditView(
                    trip: trip,
                    baseCurrency: settingsStore.baseCurrency
                )
            }
            .safeAreaInset(edge: .bottom) {
                if !locations.isEmpty {
                    PrimaryAddButton(isOnLeft: settingsStore.isAddButtonOnLeft) {
                        isShowingLocationAdd = true
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
        Section(.tripLocations) {
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
            isShowingLocationAdd = true
        }
    }
    
    private var locationListContent: some View {
        ForEach(locations) { location in
            NavigationLink {
                LocationDetailView(location: location)
            } label: {
                LocationRowView(location: location)
            }
        }
        .onDelete(perform: requestDelete)
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
