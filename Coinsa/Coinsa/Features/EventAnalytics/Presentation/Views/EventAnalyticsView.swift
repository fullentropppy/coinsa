//
//  EventAnalyticsView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import SwiftUI
import Charts

struct EventAnalyticsView: View {
    // MARK: - Внутренние типы

    private enum Metric: String, CaseIterable, Identifiable {
        case summary
        case plan
        case actual

        var id: String { rawValue }

        var localizedTitle: LocalizedStringResource {
            switch self {
            case .summary: .analyticsSummary
            case .plan: .analyticsPlan
            case .actual: .analyticsActual
            }
        }
    }

    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Хранимые свойства

    private let screenContextSubtitle: String
    private let data: EventCategoryAnalyticsData

    // MARK: - Состояние

    @State private var selectedMetric: Metric = .summary

    // MARK: - Вычисляемые свойства

    private var currentSlices: [CategoryAnalyticsSlice] {
        var slices: [CategoryAnalyticsSlice]
        
        switch selectedMetric {
        case .summary: slices = data.plannedAmountByCategory
        case .plan: slices = data.plannedAmountByCategory
        case .actual: slices = data.actualAmountByCategory
        }
        
        return slices.contains { $0.baseAmount > 0 } ? slices : []
    }

    private var displayedSlicesSortedByID: [CategoryAnalyticsSlice] {
        currentSlices.sorted { $0.category.id > $1.category.id }
    }

    private var displayedSlicesSortedByAmout: [CategoryAnalyticsSlice] {
        currentSlices.sorted { $0.baseAmount > $1.baseAmount }
    }
    
    private var totalBaseAmount: Double {
        displayedSlicesSortedByID.reduce(0) { $0 + $1.baseAmount }
    }
    
    private var totalLocalAmount: Double {
        displayedSlicesSortedByID.reduce(0) { $0 + ($1.localAmount ?? 0) }
    }
    
    // MARK: - Инициализация

    init(screenContextSubtitle: String, data: EventCategoryAnalyticsData) {
        self.screenContextSubtitle = screenContextSubtitle
        self.data = data
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
            metricPickerSection
            if displayedSlicesSortedByID.isEmpty {
                emptyAnalyticsContent
            } else {
                sectorMarkSection
                sectorMarkLegendSection
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
    
    // MARK: - Секции
    
    private var metricPickerSection: some View {
        Section {
            Picker("", selection: $selectedMetric) {
                ForEach(Metric.allCases) { metric in
                    Text(metric.localizedTitle).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedMetric) {
                haptics.trigger(.tap)
            }
        }
    }
    
    private var sectorMarkSection: some View {
        Section {
            HStack {
                Image(systemName: "sum")
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                VStack(alignment: .center, spacing: 2) {
                    if let localCurrency = data.localCurrency {
                        AmountText.standard(totalLocalAmount, currency: localCurrency)
                        AmountText.secondarySmall(totalBaseAmount, currency: data.baseCurrency)
                    } else {
                        AmountText.standard(totalBaseAmount, currency: data.baseCurrency)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
            
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
                if let localCurrency = data.localCurrency, let localAmount = slice.localAmount {
                    AmountText.standard(localAmount, currency: localCurrency)
                    AmountText.secondarySmall(slice.baseAmount, currency: data.baseCurrency)
                } else {
                    AmountText.standard(slice.baseAmount, currency: data.baseCurrency)
                }
            }
        }
    }

    // MARK: - Вспомогательные методы

    private func amountValue(for slice: CategoryAnalyticsSlice) -> Double {
        if let localAmount = slice.localAmount, data.localCurrency != nil {
            return localAmount
        }
        return slice.baseAmount
    }

    private func shareValue(for slice: CategoryAnalyticsSlice) -> Double {
        totalBaseAmount > 0 ? slice.baseAmount / totalBaseAmount : 0
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
            EventAnalyticsView(screenContextSubtitle: screenContextSubtitle, data: analyticsData)
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
