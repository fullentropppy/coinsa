//
//  ProgressBarPalette.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import SwiftUI

/// Цвета и неравномерные пороги состояния полосы прогресса.
enum ProgressBarPalette {
    /// Зеленый цвет обычной полосы и наиболее благоприятного состояния.
    static let plain: Color = .Progress.step01
    /// Красный цвет критического состояния, в том числе пустой полосы остатка.
    static let critical: Color = .Progress.step10

    /// Нижние включенные границы в процентах, от благоприятного состояния к критическому.
    private static let steps: [(minimumPercent: Double, color: Color)] = [
        (90, plain),
        (80, .Progress.step02),
        (65, .Progress.step03),
        (50, .Progress.step04),
        (40, .Progress.step05),
        (30, .Progress.step06),
        (20, .Progress.step07),
        (10, .Progress.step08),
        (5, .Progress.step09),
        (0, critical)
    ]

    /// Выбирает цвет состояния с зеркальными порогами для отрицательного прогресса.
    /// - Parameters:
    ///   - progress: Доля заполнения в диапазоне от нуля до единицы.
    ///   - reversed: Ухудшать состояние при увеличении заполнения.
    static func color(for progress: Double, reversed: Bool = false) -> Color {
        let percent = progress * 100
        return steps.first { step in
            reversed ? percent <= 100 - step.minimumPercent : percent >= step.minimumPercent
        }?.color ?? critical
    }
}
