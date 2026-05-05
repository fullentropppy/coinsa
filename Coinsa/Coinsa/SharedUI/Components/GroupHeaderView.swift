//
//  GroupHeaderView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import SwiftUI

/// Заголовок для секции группы, отображающий иконку, основной текст и опционально подтекст.
struct GroupHeaderView: View {
    // MARK: - Свойства
    
    let icon: String
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?
    
    // MARK: - Тело View
    
    /// Создает заголовок секции группы.
    /// - Parameters:
    ///   - icon: Название системной иконки.
    ///   - title: Заголовок.
    ///   - subtitle: Подазголовок (опционально).
    init(icon: String, title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: icon)
                    .imageScale(.small)
                Text(title)
                    .fontWeight(.semibold)
            }
            if let subtitle {
                Divider()
                    .frame(width: 80)
                Text(subtitle)
                    .font(.caption)
                    .padding(1)
            }
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Превью

private extension GroupHeaderView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        GroupHeaderView(
            icon: Location.primaryIcon,
            title: .tripLocations,
            subtitle: .totalNumber(number: 4.numberFormat(fractionLength: 0))
        )
            .environment(\.locale, locale)
            .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    GroupHeaderView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    GroupHeaderView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
