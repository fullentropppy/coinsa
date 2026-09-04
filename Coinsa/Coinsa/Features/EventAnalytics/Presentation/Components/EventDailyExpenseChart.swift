//
//  EventDailyExpenseChart.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.09.2026.
//

import Charts
import SwiftUI

/// График дневных расходов события.
struct EventDailyExpenseChart: View {
    // MARK: - Статические свойства
    
    static let secondsPerDay: TimeInterval = 24 * 60 * 60
    
    // MARK: - Состояние

    @State private var scrollPosition: Date

    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel

    // MARK: - Инициализация

    /// Создает график дневных расходов.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
        self._scrollPosition = State(initialValue: viewModel.summaryChartInitialScrollPosition)
    }

    // MARK: - Тело View

    var body: some View {
        VStack(spacing: 12) {
            dailyExpenseChart.frame(height: 200)
            chartControls
        }
    }

    // MARK: - Компоненты

    private var dailyExpenseChart: some View {
        Chart {
            ForEach(viewModel.summaryExpenseChartPoints) { point in
                AreaMark(
                    x: .value("", point.date.startOfDay(using: .current)),
                    yStart: .value("", 0),
                    yEnd: .value("", point.baseAmount)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(Color.accentColor.opacity(0.2).gradient)

                LineMark(
                    x: .value("", point.date.startOfDay(using: .current)),
                    y: .value("", point.baseAmount)
                )
                .interpolationMethod(.monotone)
                .lineStyle(.init(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Color.accentColor.gradient)
            }

            if viewModel.maxDailyBaseExpenseAmount > 0 {
                RuleMark(y: .value("", viewModel.maxDailyBaseExpenseAmount))
                    .lineStyle(.init(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary.opacity(0.8))
            }

            if viewModel.middleDailyBaseExpenseAmount > 0 {
                RuleMark(y: .value("", viewModel.middleDailyBaseExpenseAmount))
                    .lineStyle(.init(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary.opacity(0.8))
            }
        }
        .chartXScale(
            domain: viewModel.summaryChartXDomain,
            range: .plotDimension(startPadding: 0, endPadding: 0)
        )
        .chartYScale(
            domain: 0...viewModel.summaryChartUpperBaseAmount,
            range: .plotDimension(startPadding: 2, endPadding: 2)
        )
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) { value in
                if let date = value.as(Date.self) {
                    AxisGridLine()
                    AxisValueLabel {
                        Text(date, format: .dateTime.day().month(.abbreviated))
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: viewModel.summaryChartXVisibleDomainLength)
        .chartScrollPosition(x: $scrollPosition)
        .chartScrollTargetBehavior(.valueAligned(unit: Self.secondsPerDay))
    }
    
    private var chartControls: some View {
        HStack {
            Spacer()
            scrollPositionButton(
                position: PlainDate(viewModel.summaryChartXDomain.lowerBound.storedPlainDate),
                icon: "arrow.left.to.line"
            )
            Spacer()
            scrollPositionButton(
                position: .today,
                icon: "arrow.down.to.line"
            )
            Spacer()
            scrollPositionButton(
                position: PlainDate(viewModel.summaryChartXDomain.upperBound.storedPlainDate),
                icon: "arrow.right.to.line"
            )
            Spacer()
        }
        .padding(2)
    }
    
    private func scrollPositionButton(position: PlainDate, icon: String) -> some View {
        Button {
            scrollPosition = viewModel.summaryChartScrollPosition(for: position)
        } label: {
            Image(systemName: icon)
        }
        .buttonStyle(.borderless)
        .tint(.accent)
        .frame(width: 12, height: 14, alignment: .center)
    }
}

// MARK: - Превью

private extension EventDailyExpenseChart {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                Section {
                    EventDailyExpenseChart(viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData))
                }
                .listRowBackground(Color.clear)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventDailyExpenseChart.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventDailyExpenseChart.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
