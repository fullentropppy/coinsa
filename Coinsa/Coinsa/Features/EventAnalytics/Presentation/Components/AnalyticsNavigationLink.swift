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
    
    let destination: Destination
    
    // MARK: - Инициализаци
    
    /// Создает ссылку на экран аналитики.
    /// - Parameter destination: Замыкание, создающее целевое представление.
    init(@ViewBuilder destination: () -> Destination) {
        self.destination = destination()
    }
    
    // MARK: - Тело View
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(alignment: .center) {
                Text(.analytics)
                    .font(.subheadline)
                Spacer()
                Image(systemName: "chart.xyaxis.line")
                    .imageScale(.small)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Превью

#Preview("Light - RU") {
    NavigationStack {
        List {
            AnalyticsNavigationLink {}
        }
    }
    .environment(\.locale, PreviewLocale.ru)
    .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    NavigationStack {
        List {
            AnalyticsNavigationLink {}
        }
    }
    .environment(\.locale, PreviewLocale.en)
    .preferredColorScheme(.dark)
}
