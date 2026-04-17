//
//  NowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI
import SwiftData

struct NowView: View {
    // MARK: - Окружение
    
    @Environment(\.modelContext) private var context
    @Environment(AppSettingsStore.self) private var settingsStore

    // MARK: - Состояние

    @State private var deletionHandler = DeletionHandler<Expense>()
    @State private var selectedQuickCategory: ExpenseCategory?
    @State private var expenseToEdit: Expense?

    @Query private var currentLocations: [Location]
    
    // MARK: - Инфраструктура

    private var repository: ExpenseRepository {
        ExpenseRepository(context: context)
    }
    
    private var viewModel: NowViewModel {
        NowViewModel(
            currentLocations: currentLocations,
            selectedLocationID: settingsStore.selectedCurrentLocation?.id,
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
            nowForm
                .navigationTitle(.nowNavigationTitle)
                .navigationSubtitle(viewModel.navigationSubtitle)
                .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Основной контент

    private var nowForm: some View {
        Group {
            if let selectedLocation = viewModel.selectedLocation {
                locationContent(location: selectedLocation)
                    .sheet(item: $selectedQuickCategory) { selectedCategory in
                        ExpenseEditView(
                            location: selectedLocation,
                            baseCurrency: settingsStore.baseCurrency,
                            preselectedCategory: selectedCategory
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
            icon: Location.primaryIcon,
            title: .nowEmptyStateTitle,
            description: .nowEmptyStateDescription
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
        Section(.nowQuickExpense) {
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
                GroupHeaderView(icon: Location.primaryIcon, title: .nowNoTodayExpense)
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
        Section(.nowTodayExpenses) {
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
                settingsStore.selectedCurrentLocation = viewModel.currentLocations.first(where: { $0.id == selectedID })
            }
        )
    }

    // MARK: - Действия

    private func updateSelectedLocationIfNeeded() {
        settingsStore.selectedCurrentLocation = viewModel.validSelectedLocation(
            from: settingsStore.selectedCurrentLocation
        )
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

private extension NowView {
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

        return NowView()
            .modelContainer(container)
            .environment(settingsStore)
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    NowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    NowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("No Expenses. Light - RU") {
    NowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withExpenses: false)
}

#Preview("No Expenses. Dark - EN") {
    NowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withExpenses: false)
}

#Preview("Empty. Light - RU") {
    NowView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withLocation: false, withExpenses: false)
}

#Preview("Empty. Dark - EN") {
    NowView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withLocation: false, withExpenses: false)
}
