//
//  EventExpenseChartTimeline.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import Foundation

/// Шкала дневного графика со сжатыми промежутками без трат.
struct EventExpenseChartTimeline {
    // MARK: - Внутренние типы

    struct Point: Identifiable {
        // MARK: - Хранимые свойства

        let day: EventDailyExpenseAnalyticsData
        let position: Int
        let segment: Int

        // MARK: - Вычисляемые свойства

        var id: PlainDate { day.date }
    }

    struct Gap: Identifiable {
        // MARK: - Хранимые свойства

        let dates: ClosedRange<PlainDate>
        let position: Int

        // MARK: - Вычисляемые свойства

        var id: PlainDate { dates.lowerBound }
        var hiddenDayCount: Int { dates.upperBound.days(from: dates.lowerBound) + 1 }
    }

    // MARK: - Константы

    private static let minimumEmptyDaysToCollapse = 7

    // MARK: - Хранимые свойства

    let points: [Point]
    let gaps: [Gap]

    // MARK: - Вычисляемые свойства

    var domain: ClosedRange<Double> {
        0...Double(max(points.last?.position ?? 0, 1))
    }

    var visibleLength: Double {
        Double(min(max((points.last?.position ?? 0) - 1, 1), 7))
    }

    // MARK: - Инициализация

    /// Создает шкалу, оставляя по одному пустому дню с обеих сторон длинного промежутка.
    /// - Parameter days: Дневные суммы в порядке дат, включая дни без трат.
    init(days: [EventDailyExpenseAnalyticsData]) {
        var points: [Point] = []
        var gaps: [Gap] = []
        var index = 0
        var position = 0
        var segment = 0

        while index < days.count {
            var endIndex = index + 1
            if days[index].expenseCount == 0 {
                while endIndex < days.count, days[endIndex].expenseCount == 0 {
                    endIndex += 1
                }
            }

            if days[index].expenseCount == 0,
               index > 0,
               endIndex < days.count,
               endIndex - index >= Self.minimumEmptyDaysToCollapse {
                points.append(Point(day: days[index], position: position, segment: segment))
                gaps.append(Gap(
                    dates: days[index + 1].date...days[endIndex - 2].date,
                    position: position + 1
                ))
                segment += 1
                position += 2
                points.append(Point(day: days[endIndex - 1], position: position, segment: segment))
                position += 1
            } else {
                for day in days[index..<endIndex] {
                    points.append(Point(day: day, position: position, segment: segment))
                    position += 1
                }
            }

            index = endIndex
        }

        self.points = points
        self.gaps = gaps
    }

    // MARK: - Публичные методы

    func scrollPosition(for date: PlainDate) -> Double {
        let position: Int
        if let gap = gaps.first(where: { $0.dates.contains(date) }) {
            position = gap.position
        } else {
            position = points.min {
                abs($0.day.date.days(from: date)) < abs($1.day.date.days(from: date))
            }?.position ?? 0
        }

        let latestPosition = max(domain.lowerBound, domain.upperBound - visibleLength)
        return min(max(Double(position) - visibleLength / 2, domain.lowerBound), latestPosition)
    }
}
