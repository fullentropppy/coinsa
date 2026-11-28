//
//  TripDetailView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI
import SwiftData

/// Детальный экран поездки со сводкой, локациями и общими тратами.
struct TripDetailView: View {
    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.haptics) private var haptics
    
    // MARK: - Состояние
    
    @State private var deletionHandler = DeletionHandler<Location>()
    @State private var isShowingTripEdit = false
    @State private var isShowingLocationCreate = false
    @State private var locationToEdit: Location?
    @State private var isShowingLocationDeletionError = false
    @State private var isShowingTripDeleteConfirmation = false
    @State private var isShowingTripDeletionError = false
    @State private var selectedMode: ContentMode = .locations
    @State private var analyticsScope: AnalyticsScope?
    @State private var isShowingExpenseCreate = false
    @State private var expenseToEdit: Expense?
    @State private var expenseDeletionHandler = DeletionHandler<Expense>()
    @State private var isShowingExpenseDeletionError = false
    @State private var isShowingRateRefreshConfirmation = false
    @State private var rateRefresh = TripExchangeRateRefreshViewModel()
    @State private var rateRefreshTask: Task<Void, Never>?
    @State private var currentDay = PlainDate.today

    @Query private var availableTrips: [Trip]

    // MARK: - Зависимости
    
    private let trip: Trip

    private enum ContentMode {
        case locations
        case generalExpenses
    }

    private enum AnalyticsScope: String, Identifiable {
        case trip
        case locations
        case generalExpenses

        var id: String { rawValue }
    }

    // MARK: - Константы оформления

    private enum Layout {
        /// Размер центральной панели ожидания в пунктах.
        static let progressSide: CGFloat = 160
    }

    // MARK: - Инфраструктура
    
    private var repository: LocationRepository {
        LocationRepository(context: context)
    }
    
    private var viewModel: TripDetailViewModel {
        TripDetailViewModel(trip: trip)
    }

    private var generalExpensesViewModel: TripGeneralExpensesViewModel {
        TripGeneralExpensesViewModel(trip: trip)
    }

    private var isTripAvailable: Bool {
        !availableTrips.isEmpty && !trip.isDeleted && trip.modelContext === context
    }

    private var hasSelectedItems: Bool {
        switch selectedMode {
        case .locations: trip.hasLocations
        case .generalExpenses: !generalExpensesViewModel.expenses.isEmpty
        }
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
            if isTripAvailable {
                tripDetailContent
            } else {
                Color.clear
            }
        }
        .onChange(of: isTripAvailable, initial: true) { _, available in
            if !available {
                isShowingTripEdit = false
                isShowingLocationCreate = false
                locationToEdit = nil
                isShowingExpenseCreate = false
                expenseToEdit = nil
                analyticsScope = nil
                deletionHandler.cancel()
                expenseDeletionHandler.cancel()
                isShowingRateRefreshConfirmation = false
                rateRefreshTask?.cancel()
                rateRefresh.isShowingResult = false
                dismiss()
            }
        }
        .onDisappear {
            rateRefreshTask?.cancel()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            currentDay = .today
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { currentDay = .today }
        }
    }

    private var tripDetailContent: some View {
        tripDetailForm
            .navigationTitle(trip.name)
            .toolbarTitleDisplayMode(.inline)
            .navigationDestination(item: $analyticsScope) { [trip] scope in
                AnalyticsDestinationView { [trip] in
                    switch scope {
                    case .trip:
                        EventAnalyticsView(
                            data: TripDetailViewModel(trip: trip).eventAnalyticsData,
                            navigationTitle: .analyticsNavigationTitleTrip,
                            screenContextSubtitle: trip.screenContextSubtitle
                        )
                    case .locations:
                        EventAnalyticsView(
                            data: TripDetailViewModel(trip: trip).locationsAnalyticsData,
                            navigationTitle: .analyticsNavigationTitleLocations,
                            screenContextSubtitle: trip.screenContextSubtitle
                        )
                    case .generalExpenses:
                        EventAnalyticsView(
                            data: TripGeneralExpensesViewModel(trip: trip).eventAnalyticsData,
                            navigationTitle: .analyticsNavigationTitleGeneralExpenses,
                            screenContextSubtitle: trip.screenContextSubtitle
                        )
                    }
                }
            }
            .toolbar {
                toolbarContent
            }
            .blockingOverlay(isPresented: rateRefresh.isRefreshing) {
                BlockingProgressView(
                    title: .tripRatesRefreshProgress,
                    width: Layout.progressSide,
                    height: Layout.progressSide
                )
            }
            .modifier(
                ConfirmationAlertModifier(
                    isPresented: $isShowingRateRefreshConfirmation,
                    title: .tripRatesRefreshConfirmationTitle,
                    message: .tripRatesRefreshConfirmationMessage,
                    confirmButtonTitle: .tripRatesRefreshConfirm,
                    onConfirm: refreshRates,
                    hapticTypeOnAppear: .warning
                )
            )
            .notificationAlert(
                isPresented: $rateRefresh.isShowingResult,
                title: rateRefresh.isError ? .tripRatesRefreshErrorTitle : "",
                message: rateRefresh.message ?? .errorUnknownMessage,
                isError: rateRefresh.isError
            )
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
            .sheet(isPresented: $isShowingExpenseCreate) {
                ExpenseEditorView(
                    forCreateWith: trip,
                    preselectedPaymentMethod: settingsStore.selectedPaymentMethod,
                    exchangeAdjustment: settingsStore.exchangeAdjustment
                )
            }
            .sheet(item: $expenseToEdit) { expense in
                ExpenseEditorView(forEdit: expense)
            }
            .safeAreaInset(edge: .bottom) {
                if hasSelectedItems {
                    PrimaryAddButton(isOnLeft: settingsStore.isFloatingButtonOnLeft, action: createSelectedItem)
                }
            }
            .deleteConfirmationAlert(
                isPresented: $expenseDeletionHandler.isShowingDeleteConfirmation,
                title: .expenseDeleteTitle,
                message: .expenseDeleteMessage,
                onConfirm: confirmExpenseDelete,
                onCancel: { expenseDeletionHandler.cancel() }
            )
            .notificationAlert(
                isPresented: $isShowingExpenseDeletionError,
                title: .expenseStorageErrorTitle,
                message: .expenseStorageErrorDeleteMessage,
                isError: true
            )
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
            modeSummarySection
            switch selectedMode {
            case .locations:
                locationsSection
            case .generalExpenses:
                TripGeneralExpensesContentView(
                    viewModel: generalExpensesViewModel,
                    onCreate: { isShowingExpenseCreate = true },
                    onEdit: { expenseToEdit = $0 },
                    onDelete: { expenseDeletionHandler.request(for: [$0]) }
                )
            }
        }
    }
    
    // MARK: - Секции

    private var headerSection: some View {
        Section {
            EventSummaryView(
                data: viewModel.eventHeaderData,
                showsAmounts: viewModel.showsFullHeader
            )
            if viewModel.showsAnalytics {
                DetailNavigationButton(icon: AppSymbols.chartXyaxisLine, title: .analyticsNavigationTitleTrip) {
                    analyticsScope = .trip
                }
            }
        }
    }

    private var modeSummarySection: some View {
        Section {
            VStack(spacing: ViewLayout.Summary.sectionSpacing) {
                Picker(selection: $selectedMode) {
                    Text(.tripLocations).tag(ContentMode.locations)
                    Text(.tripGeneralExpenses).tag(ContentMode.generalExpenses)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedMode) {
                    haptics.trigger(.tap)
                }

                EventSummaryView(
                    data: selectedMode == .locations ? viewModel.locationsSummaryData : generalExpensesViewModel.summaryData,
                    showsHeader: false
                )
            }
            if selectedMode == .locations {
                if !trip.locationExpenses.isEmpty {
                    DetailNavigationButton(icon: AppSymbols.chartXyaxisLine, title: .analyticsNavigationTitleLocations) {
                        analyticsScope = .locations
                    }
                }
            } else if !generalExpensesViewModel.expenses.isEmpty {
                DetailNavigationButton(icon: AppSymbols.chartXyaxisLine, title: .analyticsNavigationTitleGeneralExpenses) {
                    analyticsScope = .generalExpenses
                }
            }
        } footer: {
            switch selectedMode {
            case .locations:
                if trip.locationsCount > 0 {
                    CountLabel.secondarySmall(trip.locationsCount, icon: Location.primaryIcon)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            case .generalExpenses:
                if viewModel.generalExpensesCount > 0 {
                    CountLabel.secondarySmall(viewModel.generalExpensesCount, icon: Expense.primaryIcon)
                        .frame(maxWidth: .infinity, alignment: .center)
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
        ForEach(viewModel.groupedLocations, id: \.status) { group in
            Section(group.status.safeLocalizedResourcePlural) {
                ForEach(group.locations) { location in
                    NavigationLink { [location, tripID = trip.id] in
                        LocationDetailView(location, parentTripID: tripID)
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
    
    // MARK: - Тулбар
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            DetailActionsMenu(title: .tripActions, onEdit: {
                isShowingTripEdit = true
            }, onDelete: {
                isShowingTripDeleteConfirmation = true
            }) {
                if selectedMode == .locations && viewModel.canRefreshRates(on: currentDay) {
                    Button {
                        isShowingRateRefreshConfirmation = true
                    } label: {
                        Label(.tripRatesRefreshAction, systemImage: AppSymbols.arrowClockwise)
                    }
                }
            }
        }
    }

    // MARK: - Действия

    private func createSelectedItem() {
        switch selectedMode {
        case .locations: isShowingLocationCreate = true
        case .generalExpenses: isShowingExpenseCreate = true
        }
    }

    private func confirmExpenseDelete() {
        do {
            try ExpenseRepository(context: context).delete(expenseDeletionHandler.itemsPendingDeletion)
            expenseDeletionHandler.cancel()
        } catch {
            isShowingExpenseDeletionError = true
        }
    }

    private func refreshRates() {
        guard !rateRefresh.isRefreshing else { return }
        rateRefreshTask = Task {
            await rateRefresh.refresh(in: trip, using: repository)
        }
    }

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
    .blockingOverlayHost()
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("Without Locations") {
    @Previewable @State var preview = TripPreviewData()

    NavigationStack {
        TripDetailView(preview.trip)
    }
    .blockingOverlayHost()
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
