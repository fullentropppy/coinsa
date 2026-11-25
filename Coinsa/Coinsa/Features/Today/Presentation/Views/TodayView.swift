//
//  TodayView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData
import UIKit

/// Экран «Сегодня», обновляющий календарный контекст при смене дня и возвращении в приложение.
struct TodayView: View {
    // MARK: - Окружение

    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Состояние

    @State private var currentDate = Date.now

    private let allowsAutomaticRateRequests: Bool

    // MARK: - Инициализация

    /// Создает экран дня с возможностью отключить автоматическую загрузку курсов в превью.
    /// - Parameter allowsAutomaticRateRequests: Разрешать автоматические запросы справочного курса.
    init(allowsAutomaticRateRequests: Bool = true) {
        self.allowsAutomaticRateRequests = allowsAutomaticRateRequests
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            TodayContentView(date: currentDate, allowsAutomaticRateRequests: allowsAutomaticRateRequests)
        }
        .onAppear {
            currentDate = .now
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                currentDate = .now
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            currentDate = .now
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            currentDate = .now
        }
    }
}

/// Содержимое дня с выборкой актуальных локаций и единым набором вычисленных данных.
private struct TodayContentView: View {
    // MARK: - Константы

    /// Отступы заголовков секций с обнуленными стандартными отступами строк списка.
    private enum Layout {
        /// Боковые отступы заголовка от границ списка.
        static let sectionHeaderHorizontalInset: CGFloat = 16
        /// Вертикальные отступы заголовка секции.
        static let sectionHeaderVerticalInset: CGFloat = 8
    }

    // MARK: - Окружение

    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore

    // MARK: - Состояние

    @State private var viewModel = TodayViewModel()
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var isShowingDeletionError = false
    @State private var selectedQuickExpense: QuickExpenseSelection?
    @State private var expenseToEdit: Expense?
    @Query private var currentLocations: [Location]

    private let date: Date
    private let day: PlainDate
    private let allowsAutomaticRateRequests: Bool

    private var selectedLocation: Location? {
        viewModel.selectedLocation(in: currentLocations, preferredID: settingsStore.selectedLocationID)
    }

    private var rateRefreshKey: TodayRateRefreshKey? {
        selectedLocation.map { TodayRateRefreshKey(location: $0, day: day) }
    }

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    // MARK: - Инициализация

    /// Создает содержимое и выборку локаций для календарного дня устройства.
    /// - Parameters:
    ///   - date: Фактический момент, из которого в текущем часовом поясе определяются день выборки и подзаголовок.
    ///   - allowsAutomaticRateRequests: Разрешать автоматические запросы справочного курса.
    init(date: Date, allowsAutomaticRateRequests: Bool) {
        self.date = date
        self.allowsAutomaticRateRequests = allowsAutomaticRateRequests
        let day = PlainDate(date, using: .current)
        self.day = day
        let storedDay = day.storedDate
        _currentLocations = Query(
            filter: #Predicate<Location> { location in
                location.storedStartDate <= storedDay && location.storedEndDate >= storedDay
            },
            sort: \.storedEndDate,
            order: .forward
        )
    }

    // MARK: - Тело View

    var body: some View {
        ZStack {
            DaySegmentBackground(daySegment: .from(date: .now))
            Group {
                if let selectedLocation {
                    locationContent(location: selectedLocation)
                        .sheet(item: $selectedQuickExpense) { selection in
                            ExpenseEditorView(
                                forCreateWith: selectedLocation,
                                preselectedCategory: selection.category,
                                preselectedSubcategory: selection.subcategory,
                                preselectedPaymentMethod: settingsStore.selectedPaymentMethod
                            )
                        }
                        .sheet(item: $expenseToEdit) { expense in
                            ExpenseEditorView(forEdit: expense)
                        }
                        .deleteConfirmationAlert(
                            isPresented: $deletionHandler.isShowingDeleteConfirmation,
                            title: .expenseDeleteTitle,
                            message: .expenseDeleteMessage,
                            onConfirm: { confirmDelete() },
                            onCancel: { deletionHandler.cancel() }
                        )
                } else {
                    EmptyStateView(
                        icon: Location.primaryIcon,
                        title: .todayEmptyStateTitle,
                        description: .todayEmptyStateDescription
                    )
                }
            }
            .scrollContentBackground(.hidden)
        }
        .notificationAlert(
            isPresented: $isShowingDeletionError,
            title: .expenseStorageErrorTitle,
            message: .expenseStorageErrorDeleteMessage,
            isError: true
        )
        .navigationTitle(viewModel.navigationTitle(for: selectedLocation, locationsCount: currentLocations.count))
        .navigationSubtitle(DateDisplayFormatter.format(date, showsTime: false, showsWeekday: true).capitalized)
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: currentLocations.map(\.id), initial: true) { _, _ in
            updateSelectedLocationIfNeeded()
        }
        .task(id: rateRefreshKey) {
            guard allowsAutomaticRateRequests else { return }
            await viewModel.refreshRate(for: rateRefreshKey)
        }
    }

    // MARK: - Основной контент

    private func locationContent(location: Location) -> some View {
        let summary = TodaySummaryCalculator.calculate(
            for: location,
            on: day,
            showsLocationBudgetOnOverspend: settingsStore.showsLocationBudgetOnOverspend,
            overspendThreshold: settingsStore.todayBudgetOverspendThreshold
        )
        let rateKey = TodayRateRefreshKey(location: location, day: day)

        return List {
            TodayLocationSummaryView(
                location: location,
                locations: currentLocations,
                selectedLocationID: selectedLocationBinding(location: location),
                summary: summary.data,
                rateLocationToHome: viewModel.rateLocationToHome(for: location, key: rateKey),
                day: day,
                hasDayExpenses: summary.expenses.contains { $0.location === location }
            )
            TodayQuickExpensesView(subcategories: summary.quickExpenseSubcategories) { category, subcategory in
                selectedQuickExpense = QuickExpenseSelection(category: category, subcategory: subcategory)
            }
            todayExpensesSection(expenses: summary.expenses)
        }
    }

    @ViewBuilder
    private func todayExpensesSection(expenses: [Expense]) -> some View {
        if !expenses.isEmpty {
            Section {
                ForEach(expenses) { expense in
                    NavigationLink {
                        ExpenseDetailView(expense)
                    } label: {
                        ExpenseRowView(expense, showsDailySpendingExclusion: true)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        SwipeActions(
                            onDelete: { deletionHandler.request(for: [expense]) },
                            onEdit: { expenseToEdit = expense }
                        )
                    }
                }
            } header: {
                Text(.todayExpenses)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, Layout.sectionHeaderHorizontalInset)
                    .padding(.vertical, Layout.sectionHeaderVerticalInset)
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 0)
                    .fill(.regularMaterial)
            )
        }
    }

    // MARK: - Биндинги и действия

    private func selectedLocationBinding(location: Location) -> Binding<UUID> {
        Binding(
            get: { selectedLocation?.id ?? location.id },
            set: { settingsStore.selectedLocationID = $0 }
        )
    }

    private func updateSelectedLocationIfNeeded() {
        let validID = selectedLocation?.id
        if settingsStore.selectedLocationID != validID {
            settingsStore.selectedLocationID = validID
        }
    }

    private func confirmDelete() {
        do {
            try withAnimation {
                try repository.delete(deletionHandler.itemsPendingDeletion)
            }
            deletionHandler.cancel()
        } catch {
            isShowingDeletionError = true
        }
    }
}

// MARK: - Внутренние типы

private struct QuickExpenseSelection: Identifiable {
    let category: ExpenseCategory
    var subcategory: ExpenseSubcategory?

    var id: String { subcategory?.rawValue ?? category.rawValue }
}

// MARK: - Превью

#Preview("With Locations") {
    @Previewable @State var preview = PreviewEnvironment(
        trips: PreviewBuilder.builder().withScenario(.balkans).buildData()
    )

    TodayView(allowsAutomaticRateRequests: false)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}

#Preview("Without Expenses") {
    @Previewable @State var preview = PreviewEnvironment(
        trips: PreviewBuilder.builder().withScenario(.balkans).withExpenses(false).buildData()
    )

    TodayView(allowsAutomaticRateRequests: false)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}

#Preview("Empty") {
    @Previewable @State var preview = PreviewEnvironment()

    TodayView(allowsAutomaticRateRequests: false)
        .modelContainer(preview.container)
        .environment(preview.settingsStore)
}
