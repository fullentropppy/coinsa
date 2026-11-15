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
        /// Толщина вертикальной линии пропущенных дней.
        static let gapLineWidth: CGFloat = 1
        /// Длины штриха и промежутка вертикальной линии пропущенных дней.
        static let gapLineDash: [CGFloat] = [3, 3]
        /// Штрихи нижней линии и промежутки с запасом для скругленных концов.
        static let gapExpenseLineDash: [CGFloat] = [4, 8]
        /// Отступ подписи пропущенных дней под верхней границей графика.
        static let gapLabelInset: CGFloat = 4
        /// Интервал между иконкой и подписью пропущенных дней.
        static let gapLabelSpacing: CGFloat = 2
        /// Ширина кнопки прокрутки дневного графика.
        static let controlWidth: CGFloat = 12
        /// Высота кнопки прокрутки дневного графика.
        static let controlHeight: CGFloat = 14
    }

    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Состояние

    @State private var scrollPosition: Double

    // MARK: - Хранимые свойства

    private let viewModel: EventAnalyticsViewModel

    // MARK: - Инициализация

    /// Создает график дневных расходов.
    /// - Parameter viewModel: ViewModel аналитики события.
    init(viewModel: EventAnalyticsViewModel) {
        self.viewModel = viewModel
        self._scrollPosition = State(initialValue: viewModel.summaryChartTimeline.scrollPosition(for: .today))
    }

    // MARK: - Тело View

    var body: some View {
        let timeline = viewModel.summaryChartTimeline

        VStack(spacing: Layout.controlsSpacing) {
            dailyExpenseChart(timeline: timeline).frame(height: Layout.chartHeight)
            chartControls(timeline: timeline)
        }
    }

    // MARK: - Компоненты

    private func dailyExpenseChart(timeline: EventExpenseChartTimeline) -> some View {
        Chart {
            ForEach(timeline.points) { point in
                AreaMark(
                    x: .value("", point.position),
                    yStart: .value("", 0),
                    yEnd: .value("", point.day.homeAmount),
                    series: .value("", point.segment)
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
                    x: .value("", point.position),
                    y: .value("", point.day.homeAmount),
                    series: .value("", point.segment)
                )
                .interpolationMethod(.monotone)
                .lineStyle(.init(lineWidth: Layout.expenseLineWidth, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Color.accentColor.gradient)
            }

            ForEach(timeline.gaps) { gap in
                RuleMark(x: .value("", gap.position))
                .lineStyle(.init(lineWidth: Layout.gapLineWidth, dash: Layout.gapLineDash))
                .foregroundStyle(.secondary)
                .annotation(position: .overlay, alignment: .top) {
                    HStack(spacing: Layout.gapLabelSpacing) {
                        Image(systemName: "arrow.left.and.right")
                            .imageScale(.small)
                        Text(.analyticsDaysChartHiddenDays(count: gap.hiddenDayCount))
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize()
                    .padding(.top, Layout.gapLabelInset)
                }

                RuleMark(
                    xStart: .value("", gap.position - 1),
                    xEnd: .value("", gap.position + 1),
                    y: .value("", 0)
                )
                .lineStyle(.init(lineWidth: Layout.expenseLineWidth, lineCap: .round, dash: Layout.gapExpenseLineDash))
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
            domain: timeline.domain,
            range: .plotDimension(startPadding: 0, endPadding: 0)
        )
        .chartYScale(
            domain: 0...viewModel.summaryChartUpperHomeAmount,
            range: .plotDimension(startPadding: Layout.plotVerticalInset, endPadding: Layout.plotVerticalInset)
        )
        .chartXAxis {
            AxisMarks(values: timeline.points.dropLast().map(\.position)) { value in
                if let position = value.as(Int.self),
                   let point = timeline.points.first(where: { $0.position == position }) {
                    AxisGridLine()
                    AxisValueLabel {
                        Text(
                            point.day.date.storedDate,
                            format: Date.FormatStyle(calendar: .utc, timeZone: .utc).day().month(.abbreviated)
                        )
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: timeline.visibleLength)
        .chartScrollPosition(x: $scrollPosition)
        .chartScrollTargetBehavior(.valueAligned(unit: 1))
    }
    
    private func chartControls(timeline: EventExpenseChartTimeline) -> some View {
        HStack {
            Spacer()
            scrollPositionButton(
                position: timeline.domain.lowerBound,
                icon: "arrow.left.to.line"
            )
            Spacer()
            scrollPositionButton(
                position: timeline.scrollPosition(for: .today),
                icon: "arrow.down.to.line"
            )
            Spacer()
            scrollPositionButton(
                position: max(timeline.domain.lowerBound, timeline.domain.upperBound - timeline.visibleLength),
                icon: "arrow.right.to.line"
            )
            Spacer()
        }
        .padding(Layout.controlsInset)
    }
    
    private func scrollPositionButton(position: Double, icon: String) -> some View {
        Button {
            haptics.trigger(.tap)
            scrollPosition = position
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
