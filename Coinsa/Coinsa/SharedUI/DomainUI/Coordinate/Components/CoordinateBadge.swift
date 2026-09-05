//
//  CoordinateLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.08.2026.
//

import SwiftUI

/// Бейдж для отображения географических координат с иконкой местоположения.
struct CoordinateBadge: View {
    // MARK: - Свойства
    
    private let coordinate: Coordinate
    private let showsBackground: Bool
    
    // MARK: - Инициализация
        
    /// Создает бейдж с указанными координатами.
    /// - Parameters:
    ///   - coordinate: Объект координат для отображения.
    ///   - showsBackground: Отображать фон в виде капсулы. По умолчанию `true`.
    init(_ coordinate: Coordinate, withBackground showsBackground: Bool = true) {
        self.coordinate = coordinate
        self.showsBackground = showsBackground
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if showsBackground {
            coordinateBadgeContent
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.regularMaterial, in: Capsule())
                .padding(.bottom, 8)
        } else {
            coordinateBadgeContent
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Компоненты
    
    private var coordinateBadgeContent: some View {
        HStack(spacing: 4) {
            Image(systemName: "location.fill")
                .imageScale(.small)
            Text(coordinate.formattedDescription)
                .lineLimit(1)
        }
        .font(.footnote.monospacedDigit())
    }
}

// MARK: - Превью

private extension CoordinateBadge {
    static let previewCoordinate = Coordinate(
        latitude: 35.65949,
        longitude: 139.70057,
        horizontalAccuracy: 12
    )

    static func makePreview(locale: Locale, colorScheme: ColorScheme, isEditable: Bool) -> some View {
        return VStack(spacing: 20) {
            CoordinateBadge(previewCoordinate)
            CoordinateBadge(previewCoordinate, withBackground: false)
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Read. Light - RU") {
    CoordinateBadge.makePreview(locale: PreviewLocale.ru, colorScheme: .light, isEditable: false)
}

#Preview("Edit. Dark - EN") {
    CoordinateBadge.makePreview(locale: PreviewLocale.en, colorScheme: .dark, isEditable: true)
}

