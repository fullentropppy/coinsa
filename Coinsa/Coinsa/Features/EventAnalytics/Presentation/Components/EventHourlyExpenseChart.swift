//
//  EventHourlyExpenseChart.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.11.2026.
//

import Charts
import SwiftUI

/// Непрокручиваемый график сумм трат каждого часа выбранного дня.
struct EventHourlyExpenseChart: View {
    let data: EventDayExpenseAnalyticsData

    var body: some View {
        Chart {
            EventExpenseChartContent(points: chartPoints, referenceHomeAmount: data.maxHourlyHomeAmount)
        }
        .chartXScale(domain: 0...24, range: .plotDimension(startPadding: 0, endPadding: 0))
        .chartYScale(
            domain: 0...max(data.maxHourlyHomeAmount, 1),
            range: .plotDimension(
                startPadding: ViewLayout.AnalyticsExpenseChart.plotVerticalInset,
                endPadding: ViewLayout.AnalyticsExpenseChart.plotVerticalInset
            )
        )
        .chartXAxis {
            AxisMarks(values: Array(stride(from: 0, through: 24, by: 2))) { value in
                AxisGridLine()
                AxisValueLabel(collisionResolution: .disabled) {
                    if let hour = value.as(Int.self) {
                        Text(verbatim: String(hour))
                    }
                }
            }
        }
        .chartYAxis(.hidden)
        .frame(height: ViewLayout.AnalyticsExpenseChart.height)
    }

    private var chartPoints: [EventExpenseChartContent.Point] {
        let points = data.hourlyHomeAmounts.enumerated().map { hour, amount in
            EventExpenseChartContent.Point(position: hour, homeAmount: amount)
        } + [EventExpenseChartContent.Point(position: 24, homeAmount: data.hourlyHomeAmounts.last ?? 0)]

        guard let firstActiveHour = data.hourlyHomeAmounts.firstIndex(where: { $0 != 0 }),
              let lastActiveHour = data.hourlyHomeAmounts.lastIndex(where: { $0 != 0 }) else {
            return points
        }

        return points.filter {
            $0.homeAmount != 0 || $0.position < firstActiveHour || $0.position > lastActiveHour
        }
    }
}

// MARK: - Превью

#Preview {
    let trip = PreviewGenerator.makeExampleTrip(includeLocations: true, includeExpenses: true)
    let expenses = TripDetailViewModel(trip: trip).eventAnalyticsData.expenses

    List {
        EventHourlyExpenseChart(data: EventDayExpenseAnalyticsData(
            date: expenses.first.map { PlainDate($0.civilDateTime.storedDate) } ?? .today,
            expenses: expenses,
            includesLocationAmount: false
        ))
    }
}
