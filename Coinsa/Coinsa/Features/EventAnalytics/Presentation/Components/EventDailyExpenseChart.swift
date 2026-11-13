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
    // MARK: - Константы

    private enum Layout {
        /// Интервал между дневным графиком и кнопками прокрутки.
        static let controlsSpacing: CGFloat = 12
        /// Высота области дневного графика.
        static let chartHeight: CGFloat = 200
        /// Непрозрачность верхней границы заливки под графиком.
        static let areaTopOpacity: Double = 0.30
        /// Непрозрачность нижней границы заливки под графиком.
        static let areaBottomOpacity: Double = 0.01
        /// Толщина линии дневных расходов.
        static let expenseLineWidth: CGFloat = 4
        /// Толщина опорных линий максимума и среднего уровня.
        static let referenceLineWidth: CGFloat = 1
        /// Длины штриха и промежутка опорных линий.
        static let referenceLineDash: [CGFloat] = [4, 4]
        /// Непрозрачность опорных линий дневного графика.
        static let referenceLineOpacity: Double = 0.8
        /// Запас сверху и снизу области графика для линии расходов.
        static let plotVerticalInset: CGFloat = 2
        /// Внутренний отступ ряда кнопок прокрутки графика.
        static let controlsInset: CGFloat = 2
        /// Ширина кнопки прокрутки дневного графика.
        static let controlWidth: CGFloat = 12
        /// Высота кнопки прокрутки дневного графика.
        static let controlHeight: CGFloat = 14
    }

    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Состояние

    @State private var scrollPosition: Date

    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel

    // MARK: - Инициализация

    /// Создает график дневных расходов.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
        self._scrollPosition = State(initialValue: viewModel.summaryChartScrollPosition(for: .today))
    }

    // MARK: - Тело View

    var body: some View {
        VStack(spacing: Layout.controlsSpacing) {
            dailyExpenseChart.frame(height: Layout.chartHeight)
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
                    yEnd: .value("", point.homeAmount)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(Layout.areaTopOpacity),
                            Color.accentColor.opacity(Layout.areaBottomOpacity)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("", point.date.startOfDay(using: .current)),
                    y: .value("", point.homeAmount)
                )
                .interpolationMethod(.monotone)
                .lineStyle(.init(lineWidth: Layout.expenseLineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Color.accentColor.gradient)
            }

            if viewModel.maxDailyBaseExpenseAmount > 0 {
                RuleMark(y: .value("", viewModel.maxDailyBaseExpenseAmount))
                    .lineStyle(.init(lineWidth: Layout.referenceLineWidth, dash: Layout.referenceLineDash))
                    .foregroundStyle(.secondary.opacity(Layout.referenceLineOpacity))
            }

            if viewModel.halfDailyBaseExpenseAmount > 0 {
                RuleMark(y: .value("", viewModel.halfDailyBaseExpenseAmount))
                    .lineStyle(.init(lineWidth: Layout.referenceLineWidth, dash: Layout.referenceLineDash))
                    .foregroundStyle(.secondary.opacity(Layout.referenceLineOpacity))
            }
        }
        .chartXScale(
            domain: viewModel.summaryChartXDomain,
            range: .plotDimension(startPadding: 0, endPadding: 0)
        )
        .chartYScale(
            domain: 0...viewModel.summaryChartUpperHomeAmount,
            range: .plotDimension(startPadding: Layout.plotVerticalInset, endPadding: Layout.plotVerticalInset)
        )
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) { value in
                if let date = value.as(Date.self) {
                    let isLastDate = viewModel.summaryChartXDomain.upperBound.startOfDay == date.startOfDay(using: .current)
                    if !isLastDate {
                        AxisGridLine()
                        AxisValueLabel {
                            Text(date, format: .dateTime.day().month(.abbreviated))
                        }
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: viewModel.summaryChartXVisibleDomainLength)
        .chartScrollPosition(x: $scrollPosition)
        .chartScrollTargetBehavior(.valueAligned(unit: viewModel.secondsPerDay))
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
        .padding(Layout.controlsInset)
    }
    
    private func scrollPositionButton(position: PlainDate, icon: String) -> some View {
        Button {
            haptics.trigger(.tap)
            scrollPosition = viewModel.summaryChartScrollPosition(for: position)
        } label: {
            Image(systemName: icon)
        }
        .buttonStyle(.borderless)
        .tint(.accent)
        .frame(width: Layout.controlWidth, height: Layout.controlHeight, alignment: .center)
    }
}

// MARK: - Превью

#Preview {
    let viewModel = TripDetailViewModel(
        trip: PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    )

    NavigationStack {
        List {
            EventDailyExpenseChart(
                viewModel: EventAnalyticsViewModel(data: viewModel.eventAnalyticsData)
            )
            .listRowBackground(Color.clear)
        }
    }
}
