//
//  AnalyticsNavigationLink.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.04.2026.
//

import SwiftUI

/// Навигационная ссылка на экран аналитики.
struct AnalyticsNavigationLink<Destination: View>: View {
    // MARK: - Свойства
    
    private let destination: () -> Destination
    
    // MARK: - Инициализация
    
    /// Создает ссылку, откладывая подготовку аналитики до построения содержимого целевого экрана.
    /// - Parameter destination: Замыкание, создающее целевое представление при переходе.
    init(@ViewBuilder destination: @escaping () -> Destination) {
        self.destination = destination
    }
    
    // MARK: - Тело View
    
    var body: some View {
        NavigationLink {
            AnalyticsDestinationView(destination: destination)
        } label: {
            HStack {
                Text(.analytics)
                    .font(.subheadline)
                Spacer()
                AppIcon(AppSymbols.chartXyaxisLine, style: .navigationLabel)
            }
            .foregroundStyle(.secondary)
        }
    }
}

/// Откладывает вызов построителя до отображения содержимого целевого экрана навигации.
struct AnalyticsDestinationView<Content: View>: View {
    // MARK: - Хранимые свойства

    let destination: () -> Content

    // MARK: - Тело View

    var body: some View {
        destination()
    }
}

// MARK: - Превью

#Preview {
    NavigationStack {
        List {
            AnalyticsNavigationLink {}
        }
    }
}
