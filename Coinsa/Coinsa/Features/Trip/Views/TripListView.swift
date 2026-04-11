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
    
    @Query private var trips: [Trip]

    @State private var deletionHandler = DeletionHandler<Trip>()
    @State private var isShowingTripCreate = false
    @State private var tripToEdit: Trip?
    
    // MARK: - Computed Properties
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }
    
    private var viewModel: TripListViewModel {
        TripListViewModel()
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            tripListForm
                .navigationTitle(.tripNavigationTitleList)
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingTripCreate) {
                    TripEditView(trip: nil)
                }
                .sheet(item: $tripToEdit) { trip in
                    TripEditView(trip: trip)
                }
                .safeAreaInset(edge: .bottom) {
                    if !trips.isEmpty {
                        PrimaryAddButton(isOnLeft: settingsStore.isAddButtonOnLeft) {
                            isShowingTripCreate = true
                        }
                    }
                }
                .deleteConfirmationAlert(
                    isPresented: $deletionHandler.isShowingDeleteConfirmation,
                    title: .tripDeleteTitle,
                    message: .tripDeleteMessage,
                    onConfirm: { confirmDelete() },
                    onCancel: { cancelDelete() }
                )
        }
    }
    
    // MARK: - Content
    
    private var tripListForm: some View {
        Group {
            if trips.isEmpty {
                emptyTripListContent
            } else {
                tripListContent
            }
        }
    }
    
    private var tripListContent: some View {
        List {
            ForEach(viewModel.groupedTrips(from: trips), id: \.status) { group in
                Section(group.status.localizedPlural) {
                    ForEach(group.trips) { trip in
                        NavigationLink {
                            TripDetailView(trip: trip)
                        } label: {
                            TripRowView(trip: trip)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            SwipeActions(
                                onDelete: { requestDelete(for: [trip]) },
                                onEdit: { tripToEdit = trip }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var emptyTripListContent: some View {
        EmptyStateView(
            imageName: Trip.primaryIcon,
            title: .tripEmptyStateTitle,
            description: .tripEmptyStateDescription,
            buttonLabel: .tripAdd,
        ) {
            isShowingTripCreate = true
        }
    }
    
    // MARK: - Actions

    private func requestDelete(for trips: [Trip]) {
        deletionHandler.request(for: trips)
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
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withTrips: Bool = true
    ) -> some View {
        let container = PreviewBuilder.builder()
            .withScenario(.all)
            .withTrips(withTrips)
            .withExpenses(false)
            .withBudgets(false)
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
    TripListView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    TripListView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("Empty. Light - RU") {
    TripListView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withTrips: false)
}

#Preview("Empty. Dark - EN") {
    TripListView.makePreview(locale: PreviewLocale.ru, colorScheme: .dark, withTrips: false)
}
