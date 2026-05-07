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
    let itemCount: Int?
    
    // MARK: - Тело View
    
    /// Создает заголовок секции группы.
    /// - Parameters:
    ///   - icon: Название системной иконки.
    ///   - title: Заголовок.
    ///   - itemCount: Количество элементов в группе (опционально).
    init(icon: String, title: LocalizedStringResource, itemCount: Int? = nil) {
        self.icon = icon
        self.title = title
        self.itemCount = itemCount
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center, spacing: 4) {
                if let itemCount {
                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "sum")
                            .imageScale(.small)
                            .fontWeight(.light)
                        Text(String(itemCount))
                            .fontWeight(.light)
                    }
                }
                Image(systemName: icon)
                    .imageScale(.small)
                    .fontWeight(.semibold)
                Text(title)
                    .fontWeight(.semibold)
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
            itemCount: 4
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
