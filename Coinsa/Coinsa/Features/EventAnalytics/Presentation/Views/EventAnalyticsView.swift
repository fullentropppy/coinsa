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
                case .actual: planActualMainContent
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
        Group {
            summaryExpensesCountRow
            if let peakTime = viewModel.peakTime {
                summaryTimeOfDayRow(peakTime)
            }
            if let mostOftenCategorySummary = viewModel.mostOftenCategorySummary {
                summaryCategoryRow(
                    title: .analyticsSummaryMostOften,
                    summary: mostOftenCategorySummary
                )
            }
            if let biggestCostCategorySummary = viewModel.biggestCostCategorySummary {
                summaryCategoryRow(
                    title: .analyticsSummaryBiggestCost,
                    summary: biggestCostCategorySummary
                )
            }
            if let largestExpense = viewModel.largestExpense {
                summaryLargestExpenseRow(largestExpense)
            }
            if let todayYesterdayDifference = viewModel.todayYesterdayDifference {
                summaryTodayYesterdayDifferenceRow(todayYesterdayDifference)
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
                case .actual: actualHeaderContent
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
        EventSummaryView(data: viewModel.eventSummaryData)
    }
    
    private var summaryExpensesCountRow: some View {
        GroupHeaderView(
            icon: Expense.primaryIcon,
            title: .analyticsSummaryTotalExpenses,
            itemCount: viewModel.totalExpensesCount
        )
        .listRowBackground(Color.clear)
    }
    
    private func summaryTimeOfDayRow(_ data: EventDaySegmentAnalyticsData) -> some View {
        Section(.analyticsSummaryPeakTime) {
            HStack {
                Text(data.timeOfDay.localizedResource)
                Spacer()
                amountStack(baseAmount: data.baseAverageAmount, locationAmount: data.locationAverageAmount)
            }
        }
    }
    
    private func summaryCategoryRow(title: LocalizedStringResource, summary: EventCategoryAnalyticsSummary) -> some View {
        Section(title) {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        summary.category.makeBadge()
                        summary.subcategory.makeBadge()
                    }
                    HStack {
                        CountLabel.secondarySmall(summary.categoryExpenseCount, icon: summary.category.primaryIcon)
                        CountLabel.secondarySmall(summary.subcategoryExpenseCount, icon: summary.subcategory.primaryIcon)
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
    
    private func summaryTodayYesterdayDifferenceRow(_ data: EventAmountDifferenceData) -> some View {
        Section(.analyticsSummaryTrend) {
            amountStack(baseAmount: data.baseAmount, locationAmount: data.locationAmount)
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

    private var actualHeaderContent: some View {
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
                    title: .amountActualDaily,
                    baseAmount: viewModel.dailyBaseExpensesAmount,
                    baseCurrency: viewModel.baseCurrency,
                    locationAmount: viewModel.dailyLocalExpensesAmount,
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
            amountStack(baseAmount: slice.baseAmount, locationAmount: slice.locationAmount)
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
