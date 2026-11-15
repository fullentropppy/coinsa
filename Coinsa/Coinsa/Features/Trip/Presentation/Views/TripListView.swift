//
//  TripListView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.02.2026.
//

import SwiftUI
import SwiftData

/// Экран со списком всех поездок.
struct TripListView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore

    // MARK: - Состояние
    
    @State private var deletionHandler = DeletionHandler<Trip>()
    @State private var isShowingTripCreate = false
    @State private var tripToEdit: Trip?
    @State private var isShowingTripDeletionError = false

    @Query private var trips: [Trip]
    
    // MARK: - Инфраструктура
    
    private var repository: TripRepository {
        TripRepository(context: context)
    }
    
    private var viewModel: TripListViewModel {
        TripListViewModel()
    }
    
    // MARK: - Тело View
    
    var body: some View {
        NavigationStack {
            tripListForm
                .navigationTitle(.tripNavigationTitleList)
                .navigationBarTitleDisplayMode(.large)
                .sheet(isPresented: $isShowingTripCreate) {
                    TripEditorView(forCreateWith: settingsStore.homeCurrency)
                }
                .sheet(item: $tripToEdit) { trip in
                    TripEditorView(forEdit: trip)
                }
                .safeAreaInset(edge: .bottom) {
                    if !trips.isEmpty {
                        PrimaryAddButton(isOnLeft: settingsStore.isFloatingButtonOnLeft) {
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
                .notificationAlert(
                    isPresented: $isShowingTripDeletionError,
                    title: .tripStorageErrorTitle,
                    message: .tripStorageDeleteErrorMessage,
                    isError: true
                )
        }
    }
    
    // MARK: - Основной контент
    
    private var tripListForm: some View {
        Group {
            if trips.isEmpty {
                emptyTripListContent
            } else {
                tripListContent
            }
        }
    }
    
    // MARK: - Компоненты
    
    private var emptyTripListContent: some View {
        EmptyStateView(
            icon: Trip.primaryIcon,
            title: .tripEmptyStateTitle,
            description: .tripEmptyStateDescription(currentYear: DateDisplayFormatter.formatYear(.now)),
            buttonLabel: .tripAdd,
        ) {
            isShowingTripCreate = true
        }
    }
    
    private var tripListContent: some View {
        List {
            ForEach(viewModel.groupedTrips(from: trips), id: \.status) { group in
                Section(group.status.safeLocalizedResourcePlural) {
                    ForEach(group.trips) { trip in
                        NavigationLink {
                            TripDetailView(trip)
                        } label: {
                            TripRowView(trip)
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
    
    // MARK: - Действия

    private func requestDelete(for trips: [Trip]) {
        deletionHandler.request(for: trips)
    }

    private func confirmDelete() {
        do {
            try withAnimation {
                try repository.delete(deletionHandler.itemsPendingDeletion)
            }
            deletionHandler.cancel()
        } catch {
            isShowingTripDeletionError = true
        }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
}

// MARK: - Превью

private extension TripListView {
    static func makePreview(withTrips: Bool = true) -> some View {
        let container = PreviewBuilder.builder()
            .withScenario(.all)
            .withTrips(withTrips)
            .withExpenses(false)
            .buildContainer()
        
        let settingsStore = AppSettingsStore()
        
        return TripListView()
            .modelContainer(container)
            .environment(settingsStore)
    }
}

#Preview("With Trips") {
    TripListView.makePreview(withTrips: true)
}

#Preview("Without Trips") {
    TripListView.makePreview(withTrips: false)
}
