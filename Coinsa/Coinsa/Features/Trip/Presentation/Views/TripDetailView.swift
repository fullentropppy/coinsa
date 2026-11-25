//
//  TripDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

/// Детальный экран поездки с информацией о локациях и аналитикой.
struct TripDetailView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Состояние
    
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var isShowingTripEdit = false
    @State private var isShowingLocationCreate = false
    @State private var locationToEdit: Location?
    @State private var isShowingLocationDeletionError = false
    @State private var isShowingTripDeleteConfirmation = false
    @State private var isShowingTripDeletionError = false

    @Query private var availableTrips: [Trip]

    // MARK: - Зависимости
    
    private let trip: Trip

    // MARK: - Инфраструктура
    
    private var repository: LocationRepository {
        LocationRepository(context: context)
    }
    
    private var viewModel: TripDetailViewModel {
        TripDetailViewModel(trip: trip)
    }
    
    // MARK: - Инициализация

    /// Создает экран подробностей переданной поездки.
    /// - Parameter trip: Поездка, доступность которой отслеживается в текущем контексте.
    init(_ trip: Trip) {
        self.trip = trip
        let tripID = trip.id
        _availableTrips = Query(filter: #Predicate<Trip> { $0.id == tripID })
    }

    // MARK: - Тело View

    var body: some View {
        Group {
            if !availableTrips.isEmpty, !trip.isDeleted, trip.modelContext === context {
                tripDetailContent
            } else {
                Color.clear
            }
        }
        .onChange(of: availableTrips.isEmpty, initial: true) { _, isUnavailable in
            if isUnavailable {
                isShowingTripEdit = false
                isShowingLocationCreate = false
                locationToEdit = nil
                dismiss()
            }
        }
    }

    private var tripDetailContent: some View {
        tripDetailForm
            .navigationTitle(trip.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingTripEdit) {
                TripEditorView(forEdit: trip)
            }
            .sheet(isPresented: $isShowingLocationCreate) {
                LocationEditorView(
                    forCreateWith: trip,
                    preselectedExchangeAdjustment: settingsStore.exchangeAdjustment
                )
            }
            .sheet(item: $locationToEdit) { location in
                LocationEditorView(forEdit: location)
            }
            .safeAreaInset(edge: .bottom) {
                if trip.hasLocations {
                    PrimaryAddButton(isOnLeft: settingsStore.isFloatingButtonOnLeft) {
                        isShowingLocationCreate = true
                    }
                }
            }
            .deleteConfirmationAlert(
                isPresented: $deletionHandler.isShowingDeleteConfirmation,
                title: .locationDeleteTitle,
                message: .locationDeleteMessage,
                onConfirm: { confirmDelete() },
                onCancel: { cancelDelete() }
            )
            .notificationAlert(
                isPresented: $isShowingLocationDeletionError,
                title: .locationStorageErrorTitle,
                message: .locationStorageErrorDeleteMessage,
                isError: true
            )
            .deleteConfirmationAlert(
                isPresented: $isShowingTripDeleteConfirmation,
                title: .tripDeleteTitle,
                message: .tripDeleteMessage,
                onConfirm: confirmTripDelete,
                onCancel: { isShowingTripDeleteConfirmation = false }
            )
            .notificationAlert(
                isPresented: $isShowingTripDeletionError,
                title: .tripStorageErrorTitle,
                message: .tripStorageErrorDeleteMessage,
                isError: true
            )
    }
    
    // MARK: - Основной контент
    
    private var tripDetailForm: some View {
        List {
            headerSection
            locationsSection
        }
    }
    
    // MARK: - Секции

    private var headerSection: some View {
        Section {
            EventSummaryView(
                data: viewModel.eventHeaderData,
                showsAmounts: viewModel.showsFullHeader
            )
            NavigationLink { [trip] in
                TripGeneralExpensesView(trip)
            } label: {
                HStack {
                    Text(.tripGeneralExpenses)
                        .font(.subheadline)
                    Spacer()
                    CountLabel.secondarySmall(viewModel.generalExpensesCount, icon: Expense.primaryIcon)
                }
                .foregroundStyle(.secondary)
            }
            if viewModel.showsFullHeader {
                AnalyticsNavigationLink { [trip] in
                    EventAnalyticsView(
                        data: TripDetailViewModel(trip: trip).eventAnalyticsData,
                        screenContextSubtitle: trip.screenContextSubtitle
                    )
                }
            }
        }
    }
    
    private var locationsSection: some View {
        Group {
            if trip.hasLocations {
                locationListContent
            } else {
                emptyLocationListContent
            }
        }
    }

    // MARK: - Компоненты

    private var emptyLocationListContent: some View {
        EmptyStateView(
            icon: Location.primaryIcon,
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
            GroupHeader(
                icon: Location.primaryIcon,
                title: .tripLocations,
                itemCount: trip.locationsCount
            )
            .listRowBackground(Color.clear)
            
            ForEach(viewModel.groupedLocations, id: \.status) { group in
                Section(group.status.safeLocalizedResourcePlural) {
                    ForEach(group.locations) { location in
                        NavigationLink {
                            LocationDetailView(location)
                        } label: {
                            LocationRowView(location)
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
    
    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            DetailActionsMenu(title: .tripActions, onEdit: {
                isShowingTripEdit = true
            }, onDelete: {
                isShowingTripDeleteConfirmation = true
            })
        }
    }

    // MARK: - Действия

    private func confirmTripDelete() {
        do {
            try TripRepository(context: context).delete(trip)
            dismiss()
        } catch {
            isShowingTripDeletionError = true
        }
    }
    
    private func requestDelete(for locations: [Location]) {
        deletionHandler.request(for: locations)
    }

    private func confirmDelete() {
        do {
            try withAnimation {
                try repository.delete(deletionHandler.itemsPendingDeletion)
            }
            deletionHandler.cancel()
        } catch {
            isShowingLocationDeletionError = true
        }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }

}

// MARK: - Превью

#Preview("With Locations") {
    @Previewable @State var preview = TripPreviewData(includeLocations: true, includeExpenses: true)

    NavigationStack {
        TripDetailView(preview.trip)
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("Without Locations") {
    @Previewable @State var preview = TripPreviewData()

    NavigationStack {
        TripDetailView(preview.trip)
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
