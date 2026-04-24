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
        case budget
        case expense

        var id: String { rawValue }

        var localizedTitle: LocalizedStringResource {
            switch self {
            case .budget: .amountPlanned
            case .expense: .amountActual
            }
        }
    }

    // MARK: - Хранимые свойства

    private let screenContextSubtitle: String
    private let data: EventCategoryAnalyticsData

    // MARK: - Состояние

    @State private var selectedMetric: Metric = .budget

    // MARK: - Вычисляемые свойства

    private var currentSlices: [CategoryAnalyticsSlice] {
        switch selectedMetric {
        case .budget: data.budgetByCategory
        case .expense: data.expenseByCategory
        }
    }

    private var displayedSlices: [CategoryAnalyticsSlice] {
        currentSlices
            .filter { amountValue(for: $0) > 0 }
            .sorted { amountValue(for: $0) > amountValue(for: $1) }
    }

    private var totalAmount: Double {
        displayedSlices.reduce(0) { $0 + amountValue(for: $1) }
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
            if displayedSlices.isEmpty {
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
        }
    }
    
    private var sectorMarkSection: some View {
        Section {
            Chart(displayedSlices) { slice in
                SectorMark(
                    angle: .value("", amountValue(for: slice)),
                    innerRadius: 60,
                    angularInset: 1,
                    
                )
                .cornerRadius(4)
                .foregroundStyle(slice.category.accentColor.gradient)
            }
            .frame(height: 200)
        }
        .listRowBackground(Color.clear)
    }
    
    @ViewBuilder
    private var sectorMarkLegendSection: some View {
            Section {
                ForEach(displayedSlices) { slice in
                    legendRow(for: slice)
                }
            }
    }
    
    // MARK: - Компоненты
    
    private func legendRow(for slice: CategoryAnalyticsSlice) -> some View {
        HStack {
            Text(shareValue(for: slice), format: .percent.precision(.fractionLength(0)))
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 38, alignment: .leading)
            
            slice.category.makeDot()
            Text(slice.category.localizedResource)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
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
        guard totalAmount > 0 else { return 0 }
        return amountValue(for: slice) / totalAmount
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
            let viewModel = TripDetailViewModel(trip: trip, baseCurrency: .defaultValue)
            screenContextSubtitle = trip.screenContextSubtitle
            analyticsData = viewModel.eventAnalyticsData
        } else {
            let location = builder.getLocation(from: data)
            let viewModel = LocationDetailViewModel(location: location, baseCurrency: .defaultValue)
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
