//
//  ProgressBarPalette.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 16.11.2026.
//

import SwiftUI

/// Цвета и неравномерные пороги состояния полосы прогресса.
enum ProgressBarPalette {
    // MARK: - Константы

    /// Зеленый цвет обычной полосы и наиболее благоприятного состояния.
    static let plain: Color = .Progress.step01
    /// Красный цвет критического состояния, в том числе пустой полосы остатка.
    static let critical: Color = .Progress.step10

    // MARK: - Свойства

    /// Нижние включенные границы в процентах, от благоприятного состояния к критическому.
    private static let steps: [(minimumPercent: Double, color: Color)] = [
        (75, plain),
        (60, .Progress.step02),
        (45, .Progress.step03),
        (35, .Progress.step04),
        (25, .Progress.step05),
        (20, .Progress.step06),
        (15, .Progress.step07),
        (10, .Progress.step08),
        (5, .Progress.step09),
        (0, critical)
    ]

    // MARK: - Методы

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
