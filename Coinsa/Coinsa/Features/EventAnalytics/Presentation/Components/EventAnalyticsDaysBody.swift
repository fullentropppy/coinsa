//
//  EventAnalyticsDaysBody.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 23.08.2026.
//

import Charts
import SwiftUI

/// Тело вкладки дневной аналитики расходов события.
struct EventAnalyticsDaysBody: View {
    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel

    // MARK: - Инициализация

    /// Создает тело вкладки дневной аналитики.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Тело View

    var body: some View {
        daysContent
    }

    // MARK: - Основной контент

    private var daysContent: some View {
        Group {
            dailyExpenseChartSection
            dailyExpensesSection
        }
    }

    // MARK: - Секции

    private var dailyExpenseChartSection: some View {
        Section {
            dailyExpenseChart
                .frame(height: 180)
        }
        .listRowBackground(Color.clear)
    }

    private var dailyExpensesSection: some View {
        Section {
            ForEach(viewModel.summaryExpenseChartPoints) { point in
                if point.baseAmount > 0 {
                    dailyExpenseRow(point)
                }
            }
        }
    }

    // MARK: - Компоненты

    private var dailyExpenseChart: some View {
        Chart {
            ForEach(viewModel.summaryExpenseChartPoints) { point in
                LineMark(
                    x: .value("", point.date.startOfDay),
                    y: .value("", point.baseAmount)
                )
                .interpolationMethod(.monotone)
                .lineStyle(.init(lineWidth: 4, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Color.accentColor.gradient)
                
                AreaMark(
                    x: .value("", point.date.startOfDay),
                    yStart: .value("", 0),
                    yEnd: .value("", point.baseAmount)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(Color.accentColor.opacity(0.2).gradient)
            }

            if viewModel.maxDailyBaseExpenseAmount > 0 {
                RuleMark(y: .value("", viewModel.maxDailyBaseExpenseAmount))
                    .lineStyle(.init(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary.opacity(0.8))
            }

            if viewModel.averageDailyBaseExpenseAmount > 0 {
                RuleMark(y: .value("", viewModel.averageDailyBaseExpenseAmount))
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
            AxisMarks(values: viewModel.summaryChartXAxisInteriorValues) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(Calendar.utc.component(.day, from: date).formatted())
                            .padding(.vertical, 3.4)
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                if let plotFrame = proxy.plotFrame {
                    let frame = geometry[plotFrame]
                    summaryChartXAxisEdgeLabelsOverlay(proxy: proxy, plotFrame: frame)
                }
            }
        }
    }

    private func dailyExpenseRow(_ point: EventDailyExpenseAnalyticsData) -> some View {
        HStack {
            DateLabel(point.date.startOfDay, withTime: false, using: .utc)
                .frame(maxHeight: .infinity, alignment: .topLeading)
            Spacer()
            AmountStack(
                baseAmount: point.baseAmount,
                baseCurrency: viewModel.baseCurrency,
                expenseAmount: point.locationAmount,
                expenseCurrency: viewModel.locationCurrency
            )
        }
    }

    private func summaryChartXAxisEdgeLabelsOverlay(proxy: ChartProxy, plotFrame: CGRect) -> some View {
        ForEach(Array(viewModel.summaryChartXAxisEdgeValues.enumerated()), id: \.element) { index, date in
            if let xPosition = proxy.position(forX: date) {
                let labelWidth: CGFloat = 44
                let isLeadingLabel = index == 0

                Text(Calendar.utc.component(.day, from: date).formatted())
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: labelWidth, alignment: isLeadingLabel ? .leading : .trailing)
                    .position(
                        x: plotFrame.minX + xPosition + (isLeadingLabel ? labelWidth / 2 : -labelWidth / 2),
                        y: plotFrame.maxY + 14
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Превью

private extension EventAnalyticsDaysBody {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let builder = PreviewBuilder.builder().withScenario(.southKorea).withExpenses(true)
        let data = builder.buildData()
        let trip = builder.getTrip(from: data)
        let viewModel = TripDetailViewModel(trip: trip)

        return NavigationStack {
            List {
                EventAnalyticsDaysBody(viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData))
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    EventAnalyticsDaysBody.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    EventAnalyticsDaysBody.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
