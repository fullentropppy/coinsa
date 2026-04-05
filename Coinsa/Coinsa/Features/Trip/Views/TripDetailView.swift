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
            .toolbarTitleDisplayMode(.large)
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
                    PrimaryAddButtonView(isOnLeft: settingsStore.isAddButtonOnLeft) {
                        isShowingLocationAdd = true
                    }
                }
            }
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
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
        Form {
            headerSection
            locationsSection
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        let showsAll = !locations.isEmpty
        return Section {
            EventSummaryView(
                data: viewModel.eventHeaderData,
                showsAmounts: showsAll,
                showsDifference: showsAll
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
            ToolbarButtonView.edit {
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
        withLocations: Bool,
        locale: Locale,
        colorScheme: ColorScheme
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
    TripDetailView.makePreview(
        withLocations: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Dark - EN") {
    TripDetailView.makePreview(
        withLocations: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Empty List. Light - RU") {
    TripDetailView.makePreview(
        withLocations: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Empty List. Dark - EN") {
    TripDetailView.makePreview(
        withLocations: false, locale: PreviewLocale.ru.locale, colorScheme: .dark
    )
}
