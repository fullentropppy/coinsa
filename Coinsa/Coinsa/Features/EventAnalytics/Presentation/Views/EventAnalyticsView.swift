//
//  EventAnalyticsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import SwiftUI
import Charts

/// Экран аналитики события с сводными данными и графиками.
struct EventAnalyticsView: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Состояние

    @State private var selectedMetric: EventAnalyticsMetric = .summary
    @State private var categoryAmountMode: CategoryAmountMode = .total
    
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    private let screenContextSubtitle: String
    
    // MARK: - Вычисляемые свойства

    private var displayedSlicesSortedByID: [ExpenseAnalyticsSlice] {
        viewModel.displayedSlicesSortedByID(for: selectedMetric)
    }

    private var displayedSlicesSortedByAmout: [ExpenseAnalyticsSlice] {
        viewModel.displayedSlicesSortedByAmount(for: selectedMetric)
    }
    
    private var categoryAmountDivisor: Double {
        switch categoryAmountMode {
        case .total: 1
        case .daily: max(viewModel.totalDays, 1)
        }
    }
    
    // MARK: - Инициализация

    /// Создает экран аналитики.
    /// - Parameters:
    ///   - data: Аналитические данные события.
    ///   - screenContextSubtitle: Подзаголовок экрана.
    init(data: EventCategoryAnalyticsData, screenContextSubtitle: String) {
        self.viewModel = EventAnalyticsViewModel(data: data)
        self.screenContextSubtitle = screenContextSubtitle
    }

    // MARK: - Тело View

    var body: some View {
        eventAnalyticsForm
            .navigationTitle(.analytics)
            .navigationSubtitle(screenContextSubtitle)
            .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Основной контент
    
    private var eventAnalyticsForm: some View {
        List {
            sharedHeaderSection
            if viewModel.hasAnalytics(for: selectedMetric) {
                switch selectedMetric {
                case .summary: summaryMainContent
                case .categories: planActualMainContent
                }
            } else {
                emptyAnalyticsContent
            }
        }
    }
    
    private var emptyAnalyticsContent: some View {
        EmptyStateView(
            icon: "chart.xyaxis.line",
            title: .analyticsEmptyState
        )
        .listRowBackground(Color.clear)
    }

    
    private var planActualMainContent: some View {
        Group {
            sectorMarkSection
            sectorMarkLegendSection
        }
    }
    
    private var summaryMainContent: some View {
        Section {
            summaryExpensesCountRow
            if let peakTime = viewModel.peakTime {
                summaryTimeOfDayRow(peakTime)
            }
            if let mostOftenCategorySummary = viewModel.mostOftenCategorySummary {
                summaryCategoryRow(
                    title: .analyticsSummaryMostOften,
                    icon: "repeat",
                    summary: mostOftenCategorySummary
                )
            }
            if let biggestCostCategorySummary = viewModel.biggestCostCategorySummary {
                summaryCategoryRow(
                    title: .analyticsSummaryBiggestCost,
                    icon: "scalemass",
                    summary: biggestCostCategorySummary
                )
            }
            if let largestExpense = viewModel.largestExpense {
                summaryLargestExpenseRow(largestExpense)
            }
        }
    }
    
    // MARK: - Секции
    
    private var sharedHeaderSection: some View {
        Section {
            Picker("", selection: $selectedMetric) {
                ForEach(EventAnalyticsMetric.allCases) { metric in
                    Text(metric.localizedResource).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedMetric) {
                haptics.trigger(.tap)
            }
            .listRowSeparator(.hidden)
            
            if viewModel.hasAnalytics(for: selectedMetric) {
                switch selectedMetric {
                case .summary: summaryHeaderContent
                case .categories: categoriesHeaderContent
                }
            }
        }
    }
    
    private var sectorMarkSection: some View {
        Section {
            Chart(displayedSlicesSortedByID, id: \.category.id) { slice in
                SectorMark(
                    angle: .value("", slice.baseAmount),
                    innerRadius: 68,
                    angularInset: 1,
                )
                .cornerRadius(6)
                .foregroundStyle(slice.category.accentColor.gradient)
            }
            .frame(height: 220)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: selectedMetric)
        }
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var sectorMarkLegendSection: some View {
        Section {
            Picker("", selection: $categoryAmountMode) {
                ForEach(CategoryAmountMode.allCases) { mode in
                    Text(mode.localizedResource).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: categoryAmountMode) {
                haptics.trigger(.tap)
            }
            .listRowSeparator(.hidden)
            
            ForEach(displayedSlicesSortedByAmout) { slice in
                if slice.baseAmount > 0 {
                    NavigationLink {
                        EventSubcategoryAnalyticsView(
                            category: slice.category,
                            data: viewModel.data,
                            screenContextSubtitle: screenContextSubtitle
                        )
                    } label: {
                        legendRow(for: slice)
                    }
                }
            }
        }
    }
    
    // MARK: - Компоненты

    private var summaryHeaderContent: some View {
        VStack(spacing: 14) {
            HStack {
                EventAmountCardView(
                    title: .amountBudget,
                    baseAmount: viewModel.eventSummaryData.budgetBaseAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.eventSummaryData.budgetLocationAmount,
                    locationCurrency: viewModel.locationCurrency
                )
                EventAmountCardView(
                    title: .amountBudgetDaily,
                    baseAmount: viewModel.dailyBaseBudgetAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.dailyLocationBudgetAmount,
                    locationCurrency: viewModel.locationCurrency
                )
            }
            HStack {
                EventAmountCardView(
                    title: .amountExpenses,
                    baseAmount: viewModel.eventSummaryData.expensesBaseAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.eventSummaryData.expensesLocationAmount,
                    locationCurrency: viewModel.locationCurrency
                )
                EventAmountCardView(
                    title: .amountExpensesDaily,
                    baseAmount: viewModel.dailyBaseExpensesAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.dailyLocationExpensesAmount,
                    locationCurrency: viewModel.locationCurrency
                )
            }
            EventAmountBalanceView(
                budgetBaseAmount: viewModel.eventSummaryData.budgetBaseAmount,
                baseAmountBalance: viewModel.baseAmountBalance,
                baseCurrency: viewModel.baseCurrency,
                locationAmountBalance: viewModel.locationAmountBalance,
                locationCurrency: viewModel.locationCurrency
            )
        }
    }
    
    private var summaryExpensesCountRow: some View {
        HStack {
            Image(systemName: Expense.primaryIcon)
                .foregroundStyle(.secondary)
            Text(.analyticsSummaryTotalExpenses)
            Spacer()
            Text(viewModel.totalExpensesCount.formatted())
        }
    }
    
    private func summaryTimeOfDayRow(_ data: EventDaySegmentAnalyticsData) -> some View {
        VStack (spacing: 14) {
            HStack {
                Image(systemName: data.timeOfDay.primaryIcon)
                    .foregroundStyle(.secondary)
                Text(.analyticsSummaryPeakTime)
                Spacer()
                Text(data.timeOfDay.localizedResource)
            }
            HStack {
                Spacer()
                amountStack(baseAmount: data.baseAverageAmount, locationAmount: data.locationAverageAmount)
            }
        }
    }
    
    private func summaryCategoryRow(
        title: LocalizedStringResource,
        icon: String,
        summary: EventCategoryAnalyticsSummary
    ) -> some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                Text(title)
                Spacer()
                Text(summary.category.localizedResource)
            }
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        CountLabel.secondarySmall(summary.categoryExpenseCount, icon: summary.category.primaryIcon)
                        Text(summary.category.localizedResource)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        CountLabel.secondarySmall(summary.subcategoryExpenseCount, icon: summary.subcategory.primaryIcon)
                        Text(summary.subcategory.localizedResource)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                amountStack(baseAmount: summary.baseAmount, locationAmount: summary.locationAmount)
            }
        }
    }
    
    private func summaryLargestExpenseRow(_ expense: Expense) -> some View {
        Section(.analyticsSummaryLargestExpense) {
            NavigationLink {
                ExpenseDetailView(expense)
            } label: {
                ExpenseRowView(expense)
            }
        }
    }
    
    private func amountStack(baseAmount: Double, locationAmount: Double?) -> some View {
        VStack(alignment: .trailing, spacing: 10) {
            if let locationCurrency = viewModel.locationCurrency,
               locationCurrency != viewModel.baseCurrency,
               let locationAmount {
                AmountText.standard(locationAmount, currency: locationCurrency)
                AmountText.secondarySmall(baseAmount, currency: viewModel.baseCurrency)
            } else {
                AmountText.standard(baseAmount, currency: viewModel.baseCurrency)
            }
        }
    }

    private var categoriesHeaderContent: some View {
        HStack {
            EventAmountCardView(
                title: .amountExpenses,
                baseAmount: viewModel.expensesTotalBaseAmount,
                baseCurrency: viewModel.baseCurrency,
                locationAmount: viewModel.expensesTotalLocationAmount,
                locationCurrency: viewModel.locationCurrency
            )
            if viewModel.totalDays > 1 {
                EventAmountCardView(
                    title: .amountExpensesDaily,
                    baseAmount: viewModel.dailyBaseExpensesAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.dailyLocationExpensesAmount,
                    locationCurrency: viewModel.locationCurrency
                )
            }
        }
        
    }
    
    private func legendRow(for slice: ExpenseAnalyticsSlice) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(slice.category.localizedResource)
                HStack {
                    slice.category.makeDot()
                    Text(shareValue(for: slice).percentFormat())
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            amountStack(
                baseAmount: slice.baseAmount / categoryAmountDivisor,
                locationAmount: slice.locationAmount.map { $0 / categoryAmountDivisor }
            )
        }
    }
    
    // MARK: - Вспомогательные методы

    private func shareValue(for slice: ExpenseAnalyticsSlice) -> Double {
        viewModel.shareValue(for: slice, metric: selectedMetric)
    }
    
    private func locationAmount(for expense: Expense) -> Double? {
        if viewModel.locationCurrency != nil {
            expense.amount(in: .location)
        } else {
            nil
        }
    }
}

// MARK: - Превью

private extension EventAnalyticsView {
    static func makePreview(
        locale: Locale,
        colorScheme: ColorScheme,
        forTrip: Bool = true,
        withSignificantData: Bool = true
    ) -> some View {
        let builder = PreviewBuilder
            .builder()
            .withScenario(.southKorea)
            .withExpenses(withSignificantData)
        
        let data = builder.buildData()
        
        let screenContextSubtitle: String
        let analyticsData: EventCategoryAnalyticsData
        
        if forTrip {
            let trip = builder.getTrip(from: data)
            let viewModel = TripDetailViewModel(trip: trip)
            screenContextSubtitle = trip.screenContextSubtitle
            analyticsData = viewModel.eventAnalyticsData
        } else {
            let location = builder.getLocation(from: data)
            let viewModel = LocationDetailViewModel(location: location)
            screenContextSubtitle = location.screenContextSubtitle
            analyticsData = viewModel.eventAnalyticsData
        }
        
        return NavigationStack {
            EventAnalyticsView(data: analyticsData, screenContextSubtitle: screenContextSubtitle)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Trip. Light - RU") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Trip. Dark - EN") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}

#Preview("Location. Light - RU") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, forTrip: false)
}

#Preview("Location. Dark - EN") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, forTrip: false)
}

#Preview("Empty. Light - RU") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.ru, colorScheme: .light, withSignificantData: false)
}

#Preview("Empty. Dark - EN") {
    EventAnalyticsView.makePreview(locale: PreviewLocale.en, colorScheme: .dark, withSignificantData: false)
}
