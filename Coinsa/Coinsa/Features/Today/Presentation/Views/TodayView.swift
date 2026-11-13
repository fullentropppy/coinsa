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

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            TodayContentView(date: currentDate)
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
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Состояние

    @State private var viewModel = TodayViewModel()
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var selectedQuickExpense: QuickExpenseSelection?
    @State private var expenseToEdit: Expense?
    @Query private var currentLocations: [Location]

    private let date: Date
    private let day: PlainDate

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
    /// - Parameter date: Фактический момент, из которого в текущем часовом поясе определяются день выборки и подзаголовок.
    init(date: Date) {
        self.date = date
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
                            ExpenseEditView(
                                forCreateWith: selectedLocation,
                                preselectedCategory: selection.category,
                                preselectedSubcategory: selection.subcategory,
                                preselectedPaymentMethod: settingsStore.selectedPaymentMethod
                            )
                        }
                        .sheet(item: $expenseToEdit) { expense in
                            ExpenseEditView(forEdit: expense)
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
        .navigationTitle(viewModel.navigationTitle(for: selectedLocation, locationsCount: currentLocations.count))
        .navigationSubtitle(DateDisplayFormatter.format(date, showsTime: false, showsWeekday: true).capitalized)
        .navigationBarTitleDisplayMode(.large)
        .onChange(of: currentLocations.map(\.id), initial: true) { _, _ in
            updateSelectedLocationIfNeeded()
        }
        .task(id: rateRefreshKey) {
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
                rateLocationToHome: viewModel.rateLocationToHome(for: location, key: rateKey)
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
                        ExpenseRowView(expense)
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
                    .fill(colorScheme == .light ? Material.regular : .thin)
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
        withAnimation {
            deletionHandler.confirm { repository.delete($0) }
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

private extension TodayView {
    static func makePreview(withLocation: Bool, withExpenses: Bool) -> some View {
        var builder = PreviewBuilder.builder()
        if withLocation {
            builder = builder.withScenario(.southKorea).withExpenses(withExpenses)
        } else {
            builder = builder.withTrips(false)
        }
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore()

        return TodayView()
            .modelContainer(container)
            .environment(settingsStore)
    }
}

#Preview("With Locations") {
    TodayView.makePreview(withLocation: true, withExpenses: true)
}

#Preview("Without Expenses") {
    TodayView.makePreview(withLocation: true, withExpenses: false)
}

#Preview("Empty") {
    TodayView.makePreview(withLocation: false, withExpenses: false)
}
