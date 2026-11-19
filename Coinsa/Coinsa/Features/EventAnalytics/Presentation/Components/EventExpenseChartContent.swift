//
//  EventExpenseChartContent.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.11.2026.
//

import Charts
import SwiftUI

/// Общие линия, заливка и опорные уровни дневного и почасового графиков трат.
struct EventExpenseChartContent: ChartContent {
    struct Point: Identifiable {
        let position: Double
        let homeAmount: Double
        var segment: Int = 0

        var id: Double { position }
    }

    private enum Layout {
        /// Непрозрачность верхней границы заливки под графиком.
        static let areaTopOpacity: Double = 0.30
        /// Непрозрачность нижней границы заливки под графиком.
        static let areaBottomOpacity: Double = 0.01
        /// Толщина линии трат.
        static let expenseLineWidth: CGFloat = 4
        /// Толщина опорных линий максимума и среднего уровня.
        static let referenceLineWidth: CGFloat = 1
        /// Длины штриха и промежутка опорных линий.
        static let referenceLineDash: [CGFloat] = [4, 4]
        /// Непрозрачность опорных линий графика.
        static let referenceLineOpacity: Double = 0.8
    }

    let points: [Point]
    let referenceHomeAmount: Double
    var interpolationMethod: InterpolationMethod = .monotone

    var body: some ChartContent {
        ForEach(points) { point in
            AreaMark(
                x: .value("", point.position),
                yStart: .value("", 0),
                yEnd: .value("", point.homeAmount),
                series: .value("", point.segment)
            )
            .interpolationMethod(interpolationMethod)
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
                y: .value("", point.homeAmount),
                series: .value("", point.segment)
            )
            .interpolationMethod(interpolationMethod)
            .lineStyle(.init(lineWidth: Layout.expenseLineWidth, lineCap: .round, lineJoin: .round))
            .foregroundStyle(Color.accentColor.gradient)
        }

        if referenceHomeAmount > 0 {
            RuleMark(y: .value("", referenceHomeAmount))
                .lineStyle(.init(lineWidth: Layout.referenceLineWidth, dash: Layout.referenceLineDash))
                .foregroundStyle(.secondary.opacity(Layout.referenceLineOpacity))

            RuleMark(y: .value("", referenceHomeAmount / 2))
                .lineStyle(.init(lineWidth: Layout.referenceLineWidth, dash: Layout.referenceLineDash))
                .foregroundStyle(.secondary.opacity(Layout.referenceLineOpacity))
        }
    }
}
