//
//  EventAnalyticsLocationsBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Charts
import SwiftData
import SwiftUI

/// Диаграмма долей трат и список локаций поездки.
struct EventAnalyticsLocationsBody: View {
    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @State private var showsDailyAmounts = false
    @State private var isChartVisible = false

    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel

    // MARK: - Инициализация

    /// Создает содержимое вкладки локаций для аналитики поездки.
    /// - Parameter viewModel: ViewModel с локациями и суммами в домашней валюте поездки.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Тело View

    var body: some View {
        let locationSlices = viewModel.locationSlices
        let slices = viewModel.displayedLocationSlices(from: locationSlices, asDailyAverage: showsDailyAmounts)

        if slices.isEmpty {
            EmptyStateView(icon: "chart.xyaxis.line", title: .analyticsEmptyStateTitle)
                .listRowBackground(Color.clear)
        } else {
            if slices.count > 1 && slices.contains(where: { $0.homeAmount > 0 }) {
                locationsChartSection(slices: slices, colorOrder: locationSlices)
            }
            locationsListSection(slices: slices, colorOrder: locationSlices)
        }
    }

    // MARK: - Секции

    private func locationsChartSection(slices: [EventLocationAnalyticsSlice], colorOrder: [EventLocationAnalyticsSlice]) -> some View {
        Section {
            Chart(slices.filter { $0.homeAmount > 0 }) { slice in
                SectorMark(
                    angle: .value("", slice.amount(asDailyAverage: showsDailyAmounts)),
                    innerRadius: .fixed(ViewLayout.AnalyticsDonutChart.innerRadius),
                    angularInset: ViewLayout.AnalyticsDonutChart.angularInset
                )
                .cornerRadius(ViewLayout.AnalyticsDonutChart.sectorCornerRadius)
                .foregroundStyle(color(for: slice, in: colorOrder).gradient)
            }
            .frame(height: ViewLayout.AnalyticsDonutChart.height)
            .opacity(isChartVisible ? 1 : 0)
            .animation(.snappy, value: isChartVisible)
            .onAppear {
                isChartVisible = true
            }
        }
        .listRowBackground(Color.clear)
    }

    private func locationsListSection(slices: [EventLocationAnalyticsSlice], colorOrder: [EventLocationAnalyticsSlice]) -> some View {
        Section {
            if slices.count > 1 || slices.contains(where: { $0.location.totalDays > 1 }) {
                Picker(selection: $showsDailyAmounts) {
                    Text(.analyticsLocationsAmountTotal).tag(false)
                    Text(.analyticsLocationsAmountDaily).tag(true)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .onChange(of: showsDailyAmounts) {
                    haptics.trigger(.tap)
                }
                .listRowSeparator(.hidden)
            }

            ForEach(slices) { slice in
                NavigationLink { [location = slice.location] in
                    AnalyticsDestinationView { [location] in
                        EventAnalyticsView(
                            data: LocationDetailViewModel(location: location).eventAnalyticsData,
                            screenContextSubtitle: location.screenContextSubtitle
                        )
                    }
                } label: {
                    locationRow(for: slice, slices: slices, colorOrder: colorOrder)
                }
            }
        }
    }

    // MARK: - Компоненты

    private func locationRow(for slice: EventLocationAnalyticsSlice, slices: [EventLocationAnalyticsSlice], colorOrder: [EventLocationAnalyticsSlice]) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
                Text(slice.location.name)
                HStack(spacing: ViewLayout.Row.metadataSpacing) {
                    if slices.count > 1 {
                        DotView(color(for: slice, in: colorOrder))
                        Text(viewModel.shareValue(for: slice, among: slices, asDailyAverage: showsDailyAmounts).percentFormat())
                            .font(.footnote.monospacedDigit())
                            .foregroundStyle(.secondary)
                        DotDivider.secondarySmall()
                    }
                    CountLabel.secondarySmall(slice.expenseCount, icon: Expense.primaryIcon)
                }
            }
            Spacer()
            AmountStack(
                homeAmount: slice.amount(asDailyAverage: showsDailyAmounts),
                homeCurrency: viewModel.homeCurrency
            )
        }
    }

    // MARK: - Вспомогательные методы

    private func color(for slice: EventLocationAnalyticsSlice, in slices: [EventLocationAnalyticsSlice]) -> Color {
        let index = slices.firstIndex { $0.id == slice.id } ?? 0
        return ChartPalette.color(at: index, id: slice.id)
    }
}

// MARK: - Превью

#Preview("With Expenses") {
    @Previewable @State var preview = ExpenseMapPreviewData(forTrip: true)

    NavigationStack {
        List {
            EventAnalyticsLocationsBody(viewModel: EventAnalyticsViewModel(data: preview.analyticsData))
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}

#Preview("Without Expenses") {
    @Previewable @State var preview = ExpenseMapPreviewData(forTrip: true, includeExpenses: false)

    NavigationStack {
        List {
            EventAnalyticsLocationsBody(viewModel: EventAnalyticsViewModel(data: preview.analyticsData))
        }
    }
    .modelContainer(preview.container)
    .environment(preview.settingsStore)
}
