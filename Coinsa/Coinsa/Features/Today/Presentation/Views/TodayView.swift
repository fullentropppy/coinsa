//
//  TodayView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

/// Экран "Сегодня" для отображения данных по текущему дню.
struct TodayView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.haptics) private var haptics
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Состояние

    @State private var viewModel: TodayViewModel
    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var selectedQuickExpense: QuickExpenseSelection?
    @State private var expenseToEdit: Expense?
    @State private var selectedLocationID: UUID?

    @Query private var currentLocations: [Location]
    
    // MARK: - Инфраструктура

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }

    // MARK: - Визуальный стиль
    
    private var listRowBackgroundMaterial: Material {
        colorScheme == .light ? .regularMaterial : .thinMaterial
    }
    
    private var buttonTint: Color {
        colorScheme == .light ? .white.opacity(0.1) : .black.opacity(0.2)
    }
    
    // MARK: - Инициализация
    
    init() {
        let viewModel = TodayViewModel(
            currentLocations: [],
            selectedLocationID: nil
        )
        _viewModel = State(initialValue: viewModel)
        
        let today = PlainDate.today.storedDate
        
        _currentLocations = Query(
            filter: #Predicate<Location> { location in
                location.storedStartDate <= today && location.storedEndDate >= today
            },
            sort: \.storedEndDate,
            order: .forward
        )
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            todayForm
                .navigationTitle(viewModel.navigationTitle)
                .navigationSubtitle(viewModel.navigationSubtitle)
                .navigationBarTitleDisplayMode(.large)
                .onAppear {
                    syncViewModelContext()
                    updateSelectedLocationIfNeeded()
                }
                .onChange(of: selectedLocationID) { _, _ in
                    updateSelectedLocationIfNeeded()
                }
                .task(id: viewModel.rateRefreshKey) {
                    viewModel.loadInitialRateIfNeeded()
                }
        }
    }

    // MARK: - Основной контент

    private var todayForm: some View {
        ZStack {
            DaySegmentBackground(daySegment: .from(date: .now))
            
            Group {
                if let selectedLocation = viewModel.selectedLocation {
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
                            onCancel: { cancelDelete() }
                        )
                } else {
                    emptyCurrentLocationContent
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
    
    private var emptyCurrentLocationContent: some View {
        EmptyStateView(
            icon: Location.primaryIcon,
            title: .todayEmptyStateTitle,
            description: .todayEmptyStateDescription
        )
    }
    
    private func locationContent(location: Location) -> some View {
        List {
            locationSection(location: location)
            quickExpenseSection
            todayExpensesSection
        }
    }

    // MARK: - Секции

    private func locationSection(location: Location) -> some View {
        Section {
            VStack(spacing: 14) {
                locationPickerContent(location: location)
                locationSummaryContent(location: location)
            }
            contextContent(location: location)
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 0).fill(listRowBackgroundMaterial)
        )
    }
    
    private var quickExpenseSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
                ForEach(ExpenseCategory.allCases, id: \.id) { category in
                    quickExpenseButton(category: category)
                }
                HStack(spacing: 8) {
                    ForEach(viewModel.quickExpenseSubcategories) { subcategory in
                        quickExpenseButton(subcategory: subcategory)
                    }
                }
            }
            .padding(4)
        } header: {
            Text(.todayQuickExpense)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    @ViewBuilder
    private var todayExpensesSection: some View {
        if viewModel.hasTodayExpenses {
            Section {
                ForEach(viewModel.todayExpenses) { expense in
                    NavigationLink {
                        ExpenseDetailView(expense)
                    } label: {
                        ExpenseRowView(expense)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        SwipeActions(
                            onDelete: { requestDelete(for: [expense]) },
                            onEdit: { expenseToEdit = expense }
                        )
                    }
                }
            } header: {
                Text(.todayExpenses)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .listRowBackground(
                RoundedRectangle(cornerRadius: 0).fill(listRowBackgroundMaterial)
            )
        }
    }

    // MARK: - Компоненты
    
    @ViewBuilder
    private func locationPickerContent(location: Location) -> some View {
        if viewModel.hasMultipleLocations {
            Picker(selection: selectedLocationBinding(location: location)) {
                ForEach(viewModel.currentLocations) { currentLocation in
                    Text(currentLocation.name)
                        .tag(currentLocation.id)
                }
            } label: {
                EmptyView()
            }
            .onChange(of: selectedLocationBinding(location: location).wrappedValue) {
                haptics.trigger(.tap)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func locationSummaryContent(location: Location) -> some View {
        EventSummaryView(
            data: viewModel.eventSummaryData(
                for: location,
                showsLocationBudgetOnOverspend: settingsStore.showsLocationBudgetOnOverspend,
                overspendThreshold: settingsStore.todayBudgetOverspendThreshold
            ),
            showsHeader: false,
            showsBudgetIfZero: location.hasBudget
        )
    }
    
    private func contextContent(location: Location) -> some View {
        NavigationLink {
            LocationDetailView(location)
        } label: {
            HStack(alignment: .center) {
                if viewModel.isHomeLocation {
                    Text("\(location.name) • \(location.trip?.name ?? "")")
                        .font(.subheadline)
                } else {
                    exchangeRatesContent(location: location)
                }
                Spacer()
                Image(systemName: Location.primaryIcon)
                    .imageScale(.small)
                    .font(.subheadline.weight(.semibold))
                    
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private func exchangeRatesContent(location: Location) -> some View {
        HStack {
            Image(systemName: "arrow.left.arrow.right")
                .imageScale(.small)
                .font(.subheadline.weight(.semibold))
            
            VStack(alignment: .leading) {
                Text(
                    .todayExchangeRate(
                        baseCurrencyCode: location.locationCurrencyCode,
                        rateBaseToQuote: viewModel.rateLocationToHome.numberFormat(fractionLength: 4),
                        quoteCurrencyCode: location.trip?.baseCurrencyCode ?? "")
                )
                Text(
                    .todayExchangeRate(
                        baseCurrencyCode: location.trip?.baseCurrencyCode ?? "",
                        rateBaseToQuote: viewModel.rateHomeToLocation.numberFormat(fractionLength: 4),
                        quoteCurrencyCode: location.locationCurrencyCode)
                )
            }
            .font(.caption)
        }
    }
    
    private func quickExpenseButton(category: ExpenseCategory) -> some View {
        Button {
            haptics.trigger(.add)
            selectedQuickExpense = QuickExpenseSelection(category: category)
        } label: {
            HStack(alignment: .center) {
                Image(systemName: category.primaryIcon)
                    .frame(width: 20, height: 20)
                    .foregroundStyle(category.accentColor)
                    .shadow(color: category.accentColor, radius: 12)
                Text(category.localizedResource)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.glassProminent)
        .tint(buttonTint)
        .foregroundStyle(Color.primary)
    }
    
    private func quickExpenseButton(subcategory: ExpenseSubcategory) -> some View {
        Button {
            haptics.trigger(.add)
            selectedQuickExpense = QuickExpenseSelection(
                category: subcategory.category,
                subcategory: subcategory
            )
        } label: {
            Image(systemName: subcategory.primaryIcon)
                .frame(width: 20, height: 20)
                .foregroundStyle(subcategory.accentColor)
                .shadow(color: subcategory.accentColor, radius: 12)
                .font(.subheadline.weight(.medium))
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .tint(buttonTint)
        .foregroundStyle(Color.primary)
    }

    // MARK: - Биндинги

    private func selectedLocationBinding(location: Location) -> Binding<UUID> {
        Binding(
            get: { viewModel.selectedLocation?.id ?? location.id },
            set: { selectedID in
                selectedLocationID = selectedID
                settingsStore.selectedLocationID = selectedID
            }
        )
    }

    // MARK: - Действия

    private func syncViewModelContext(selectedLocationID: UUID? = nil) {
        viewModel.updateContext(
            currentLocations: currentLocations,
            selectedLocationID: selectedLocationID ?? self.selectedLocationID
        )
    }

    private func updateSelectedLocationIfNeeded() {
        let validID = viewModel.validSelectedLocationID(
            from: selectedLocationID ?? settingsStore.selectedLocationID
        )
        selectedLocationID = validID
        settingsStore.selectedLocationID = validID
        syncViewModelContext(selectedLocationID: validID)
    }
    
    private func requestDelete(for expenses: [Expense]) {
        deletionHandler.request(for: expenses)
    }

    private func confirmDelete() {
        withAnimation {
            deletionHandler.confirm { repository.delete($0) }
        }
    }

    private func cancelDelete() {
        deletionHandler.cancel()
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
