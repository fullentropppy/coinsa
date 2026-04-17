//
//  TodayView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore
    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var selectedQuickCategory: ExpenseCategory?
    @State private var expenseToEdit: Expense?
    @State private var selectedLocationID: UUID?

    @Query private var currentLocations: [Location]
    
    // MARK: - Инфраструктура

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }
    
    private var viewModel: TodayViewModel {
        TodayViewModel(
            currentLocations: currentLocations,
            selectedLocationID: selectedLocationID,
            baseCurrency: settingsStore.baseCurrency
        )
    }
    
    // MARK: - Инициализация
    
    init() {
        let today = Date.now
        _currentLocations = Query(
            filter: #Predicate<Location> { location in
                location.startDate <= today && location.endDate >= today
            },
            sort: \.endDate,
            order: .forward
        )
    }

    // MARK: - Тело View

    var body: some View {
        NavigationStack {
            todayForm
                .navigationTitle(.todayNavigationTitle)
                .navigationSubtitle(viewModel.navigationSubtitle)
                .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Основной контент

    private var todayForm: some View {
        Group {
            if let selectedLocation = viewModel.selectedLocation {
                locationContent(location: selectedLocation)
                    .sheet(item: $selectedQuickCategory) { selectedCategory in
                        ExpenseEditView(
                            location: selectedLocation,
                            baseCurrency: settingsStore.baseCurrency,
                            preselectedCategory: selectedCategory,
                            preselectedPaymentMethod: settingsStore.selectedPaymentMethod
                        )
                    }
                    .sheet(item: $expenseToEdit) { expense in
                        ExpenseEditView(expense, baseCurrency: settingsStore.baseCurrency)
                    }
                    .deleteConfirmationAlert(
                        isPresented: $deletionHandler.isShowingDeleteConfirmation,
                        title: .expenseDeleteTitle,
                        message: .expenseDeleteMessage,
                        onConfirm: { confirmDelete() },
                        onCancel: { cancelDelete() }
                    )
                    .onAppear {
                        updateSelectedLocationIfNeeded()
                    }
                    .onChange(of: currentLocations) { _, _ in
                        updateSelectedLocationIfNeeded()
                    }
            } else {
                emptyCurrentLocationView
            }
        }
    }
    
    private var emptyCurrentLocationView: some View {
        EmptyStateView(
            icon: "calendar",
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
                locationHeaderContent(location: location)
                locationSummaryContent(location: location)
            }
        }
    }
    
    private var quickExpenseSection: some View {
        Section(.todayQuickExpense) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
                ForEach(ExpenseCategory.allCases, id: \.id) { category in
                    quickExpenseButton(category: category)
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    @ViewBuilder
    private var todayExpensesSection: some View {
        Group {
            if viewModel.todayExpenses.isEmpty {
                GroupHeaderView(icon: Location.primaryIcon, title: .todayNoExpenses)
                    .listRowBackground(Color.clear)
            } else {
                todayExpenseListContent
            }
        }
    }

    // MARK: - Компоненты
    
    @ViewBuilder
    private func locationPickerContent(location: Location) -> some View {
        if viewModel.hasMultipleLocations {
            Picker("", selection: selectedLocationBinding(location: location)) {
                ForEach(viewModel.currentLocations) { currentLocation in
                    Text(currentLocation.name)
                        .tag(currentLocation.id)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private func locationHeaderContent(location: Location) -> some View {
        NavigationLink {
            LocationDetailView(location)
        } label: {
            HStack {
                if !viewModel.hasMultipleLocations {
                    Text(location.name)
                        .fontWeight(.semibold)
                    Spacer()
                }
                DateLabel.secondarySmall(from: location.startDate, to: location.endDate)
                CountLabel.daysSecondarySmall(location.durationInDays)
            }
        }
    }
    
    private func locationSummaryContent(location: Location) -> some View {
        EventSummaryView(data: viewModel.eventSummaryData(for: location), showsHeader: false)
    }
    
    private func quickExpenseButton(category: ExpenseCategory) -> some View {
        Button {
            haptics.trigger(.add)
            selectedQuickCategory = category
        } label: {
            HStack {
                Image(systemName: category.safeBadgeIcon)
                    .frame(width: 20)
                Text(category.localizedResource)
                    
            }
            .foregroundStyle(.windowBackground)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.glassProminent)
        .tint(category.badgeColor)
    }
    
    private var todayExpenseListContent: some View {
        Section(.todayExpenses) {
            ForEach(viewModel.todayExpenses) { expense in
                NavigationLink {
                    ExpenseDetailView(expense)
                } label: {
                    ExpenseRowView(expense, baseCurrency: settingsStore.baseCurrency)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    SwipeActions(
                        onDelete: { requestDelete(for: [expense]) },
                        onEdit: { expenseToEdit = expense }
                    )
                }
            }
        }
    }
    
    // MARK: - Биндинги

    private func selectedLocationBinding(location: Location) -> Binding<UUID> {
        Binding(
            get: { viewModel.selectedLocation?.id ?? location.id },
            set: { selectedID in
                haptics.trigger(.tap)
                selectedLocationID = selectedID
                settingsStore.selectedLocationID = selectedID
            }
        )
    }

    // MARK: - Действия

    private func updateSelectedLocationIfNeeded() {
        let validID = viewModel.validSelectedLocationID(
            from: selectedLocationID ?? settingsStore.selectedLocationID
        )
        selectedLocationID = validID
        settingsStore.selectedLocationID = validID
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

// MARK: - Превью

private extension TodayView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        withLocation: Bool = true,
        withExpenses: Bool = true
    ) -> some View {
        var builder = PreviewBuilder.builder()
        if withLocation {
            builder = builder.withScenario(.southKorea).withExpenses(withExpenses)
        } else {
            builder = builder.withTrips(false)
        }
        let container = builder.buildContainer()
        let settingsStore = AppSettingsStore(context: container.mainContext)

        return TodayView()
            .modelContainer(container)
            .environment(settingsStore)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    TodayView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    TodayView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("No Expenses. Light - RU") {
    TodayView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withExpenses: false)
}

#Preview("No Expenses. Dark - EN") {
    TodayView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withExpenses: false)
}

#Preview("Empty. Light - RU") {
    TodayView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withLocation: false, withExpenses: false)
}

#Preview("Empty. Dark - EN") {
    TodayView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withLocation: false, withExpenses: false)
}
