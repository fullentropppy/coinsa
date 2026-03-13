//
//  LocationListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

struct LocationListView: View {
    // MARK: - Stored Properties
    
    @Environment(\.modelContext) private var context
    
    @Query private var locations: [Location]
    
    @State private var deletionHandler = DeletionHandler<Location>(
        messageKey: "location.deletionConfirmation.message.single"
    )
    
    private let tripID: PersistentIdentifier
    private let onAddLocation: () -> Void
    
    // MARK: - Computed Properties
    
    private var repository: LocationRepository {
        LocationRepository(context: context)
    }
    
    // MARK: - Initialization
    
    init(tripID: PersistentIdentifier, onAddLocation: @escaping () -> Void) {
        self.tripID = tripID
        self.onAddLocation = onAddLocation
        
        _locations = Query(
            filter: #Predicate<Location> { $0.trip.persistentModelID == tripID },
            sort: \.startDate
        )
    }

    var body: some View {
        List {
            ForEach(locations) { location in
                NavigationLink {
                    
                } label: {
                    LocationRowView(location: location)
                }
            }
            .onDelete(perform: requestDelete)
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
        .overlay {
            if locations.isEmpty {
                EmptyStateView(
                    imageName: "mappin.and.ellipse",
                    title: "location.list.empty.title",
                    description: "location.list.empty.desctiption",
                    buttonLabel: "location.list.addLocation",
                    onAddAction: { onAddLocation() }
                )
            }
        }
    }

    // MARK: - Actions

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

private extension LocationListView {
    static func preview(
        withLocations: Bool,
        locale: Locale,
        colorScheme: ColorScheme
    ) -> some View {
        let builder = PreviewBuilder
            .builder()
            .withLocations(withLocations)
            .withExpenses(false)
            .withBudgets(false)
    
        let container = builder.buildContainer()
        let tripID = builder.fetchTrip(from: container).persistentModelID
        
        return NavigationStack {
            LocationListView(tripID: tripID, onAddLocation: {})
                .modelContainer(container)
                .environment(\.locale, locale)
                .preferredColorScheme(colorScheme)
        }
    }
}

#Preview("Light - RU") {
    LocationListView.preview(
        withLocations: true, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Dark - EN") {
    LocationListView.preview(
        withLocations: true, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

#Preview("Empty List. Light - RU") {
    LocationListView.preview(
        withLocations: false, locale: PreviewLocale.ru.locale, colorScheme: .light
    )
}

#Preview("Empty List. Dark - EN") {
    LocationListView.preview(
        withLocations: false, locale: PreviewLocale.en.locale, colorScheme: .dark
    )
}

