//
//  TripDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

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

    init(_ trip: Trip) {
        self.trip = trip
    }

    // MARK: - Тело View

    var body: some View {
        tripDetailForm
            .navigationTitle(trip.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isShowingTripEdit) {
                TripEditView(forEdit: trip) { dismiss() }
            }
            .sheet(isPresented: $isShowingLocationCreate) {
                LocationEditView(
                    forCreateWith: trip,
                    preselectedExchangeAdjustment: settingsStore.exchangeAdjustment
                )
            }
            .sheet(item: $locationToEdit) { location in
                LocationEditView(forEdit: location)
            }
            .safeAreaInset(edge: .bottom) {
                if !trip.locations.isEmpty {
                    PrimaryAddButton(isOnLeft: settingsStore.isAddButtonOnLeft) {
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
            .onAppear {
                checkIfDeleted()
            }
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
            if viewModel.showsFullHeader {
                AnalyticsNavigationLink {
                    EventAnalyticsView(
                        data: viewModel.eventAnalyticsData,
                        screenContextSubtitle: trip.screenContextSubtitle
                    )
                }
            }
        }
    }
    
    private var locationsSection: some View {
        Group {
            if trip.locations.isEmpty {
                emptyLocationListContent
            } else {
                locationListContent
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
            GroupHeaderView(icon: Location.primaryIcon, title: .tripLocations)
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
            ToolbarButton.edit {
                isShowingTripEdit = true
            }
        }
    }

    // MARK: - Действия
    
    private func requestDelete(for locations: [Location]) {
        deletionHandler.request(for: locations)
    }

    private func confirmDelete() {
        withAnimation {
            deletionHandler.confirm { repository.delete($0) }
        }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
    }
    
    private func checkIfDeleted() {
        if trip.modelContext == nil {
            dismiss()
        }
    }
}

// MARK: - Превью

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
            TripDetailView(trip)
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
