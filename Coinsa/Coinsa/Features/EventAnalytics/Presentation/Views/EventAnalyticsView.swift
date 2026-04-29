//
//  EventAnalyticsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import SwiftUI
import Charts

struct EventAnalyticsView: View {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Состояние

    @State private var selectedMetric: EventAnalyticsMetric = .summary
    @State private var selectedSummaryMode: EventAnalyticsSummaryMode = .perCategory
    
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel
    private let screenContextSubtitle: String
    
    // MARK: - Вычисляемые свойства

    private var displayedSlicesSortedByID: [CategoryAnalyticsSlice] {
        viewModel.displayedSlicesSortedByID(for: selectedMetric)
    }

    private var displayedSlicesSortedByAmout: [CategoryAnalyticsSlice] {
        viewModel.displayedSlicesSortedByAmount(for: selectedMetric)
    }

    private var categoryProgressItems: [EventAnalyticsCategoryProgressItem] {
        viewModel.categoryProgressItems(for: selectedSummaryMode)
    }
    
    // MARK: - Инициализация

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
                case .plan, .actual: planActualMainContent
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
    
    private var summaryMainContent: some View {
        Group {
            summaryCategoriesSection
        }
    }
    
    private var planActualMainContent: some View {
        Group {
            sectorMarkSection
            sectorMarkLegendSection
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
                case .plan: planHeaderContent
                case .actual: actualHeaderContent
                }
            }
        }
    }
    
    private var summaryCategoriesSection: some View {
        Section {
            Picker("", selection: $selectedSummaryMode) {
                ForEach(EventAnalyticsSummaryMode.allCases) { mode in
                    Text(mode.localizedResource).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedSummaryMode) {
                haptics.trigger(.tap)
            }
            .listRowSeparator(.hidden)
            
            ForEach(categoryProgressItems) { item in
                EventAmountProgressView(
                    plannedBaseAmount: item.plannedBaseAmount,
                    baseActualAmount: item.actualBaseAmount,
                    baseCurrency: viewModel.baseCurrency,
                    localPlannedAmount: item.plannedLocalAmount,
                    localActualAmount: item.actualLocalAmount,
                    localCurrency: viewModel.localCurrency
                ) {
                    HStack(spacing: 8) {
                        item.category.makeDot()
                        Text(item.category.localizedResource)
                    }
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
                legendRow(for: slice)
            }
        }
    }
    
    // MARK: - Компоненты

    private var summaryHeaderContent: some View {
        EventSummaryView(data: viewModel.eventSummaryData)
    }
    
    private var planHeaderContent: some View {
        HStack {
            EventAmountCardView(
                title: .amountPlan,
                baseAmount: viewModel.plannedTotalBaseAmount,
                baseCurrency: viewModel.baseCurrency,
                localAmount: viewModel.plannedTotalLocalAmount,
                localCurrency: viewModel.localCurrency
            )
            EventAmountCardView(
                title: .amountPlanDaily,
                baseAmount: viewModel.dailyBasePlannedAmount,
                baseCurrency: viewModel.baseCurrency,
                localAmount: viewModel.dailyLocalPlannedAmount,
                localCurrency: viewModel.localCurrency
            )
        }
    }
    
    private var actualHeaderContent: some View {
        HStack {
            EventAmountCardView(
                title: .amountActual,
                baseAmount: viewModel.actualTotalBaseAmount,
                baseCurrency: viewModel.baseCurrency,
                localAmount: viewModel.actualTotalLocalAmount,
                localCurrency: viewModel.localCurrency
            )
            EventAmountCardView(
                title: .amountActualDaily,
                baseAmount: viewModel.dailyBaseActualAmount,
                baseCurrency: viewModel.baseCurrency,
                localAmount: viewModel.dailyLocalActualAmount,
                localCurrency: viewModel.localCurrency
            )
        }
        
    }
    
    private func legendRow(for slice: CategoryAnalyticsSlice) -> some View {
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
            VStack(alignment: .trailing, spacing: 10) {
                if let localCurrency = viewModel.localCurrency, let localAmount = slice.localAmount {
                    AmountText.standard(localAmount, currency: localCurrency)
                    AmountText.secondarySmall(slice.baseAmount, currency: viewModel.baseCurrency)
                } else {
                    AmountText.standard(slice.baseAmount, currency: viewModel.baseCurrency)
                }
            }
        }
    }

    // MARK: - Вспомогательные методы

    private func shareValue(for slice: CategoryAnalyticsSlice) -> Double {
        viewModel.shareValue(for: slice, metric: selectedMetric)
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
        let builder = PreviewBuilder.builder()
            .withBudgets(withSignificantData)
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
