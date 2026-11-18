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
        static let controlsSpacing: CGFloat = 14
        /// Толщина нижней линии пропущенных дней.
        static let gapExpenseLineWidth: CGFloat = 4
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
            dailyExpenseChart(timeline: timeline).frame(height: ViewLayout.AnalyticsExpenseChart.height)
            chartControls(timeline: timeline)
        }
    }

    // MARK: - Компоненты

    private func dailyExpenseChart(timeline: EventExpenseChartTimeline) -> some View {
        Chart {
            EventExpenseChartContent(
                points: timeline.points.map {
                    EventExpenseChartContent.Point(
                        position: $0.position,
                        homeAmount: $0.day.homeAmount,
                        segment: $0.segment
                    )
                },
                referenceHomeAmount: viewModel.maxDailyBaseExpenseAmount
            )

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
                .lineStyle(.init(lineWidth: Layout.gapExpenseLineWidth, lineCap: .round, dash: Layout.gapExpenseLineDash))
                .foregroundStyle(Color.accentColor.gradient)
            }
        }
        .chartXScale(
            domain: timeline.domain,
            range: .plotDimension(startPadding: 0, endPadding: 0)
        )
        .chartYScale(
            domain: 0...viewModel.summaryChartUpperHomeAmount,
            range: .plotDimension(
                startPadding: ViewLayout.AnalyticsExpenseChart.plotVerticalInset,
                endPadding: ViewLayout.AnalyticsExpenseChart.plotVerticalInset
            )
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
        HStack(alignment: .center) {
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
                .imageScale(.small)
                .fontWeight(.semibold)
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
