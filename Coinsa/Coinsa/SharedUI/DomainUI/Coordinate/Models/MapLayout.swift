//
//  MapLayout.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import Foundation

/// Общие размеры элементов управления и области отображения карт.
enum MapLayout {
    /// Отступ стандартных элементов управления от края полноэкранной карты.
    static let controlsInset: CGFloat = 8
    /// Внутренний отступ кнопок нижней панели карты.
    static let buttonPadding = ViewLayout.FloatingControls.buttonInset
    /// Отступ нижней панели карты от бокового и нижнего края.
    static let bottomBarInset = ViewLayout.FloatingControls.edgeInset

    /// Размах области вокруг выбранной координаты по широте и долготе в градусах.
    static let detailSpanDelta: Double = 0.01
    /// Размах обзорной карты без выбранной координаты в градусах.
    static let overviewSpanDelta: Double = 120
}
