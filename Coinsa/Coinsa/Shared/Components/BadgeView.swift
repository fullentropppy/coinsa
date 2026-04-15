//
//  BadgeView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

struct BadgeView: View {
    // MARK: - Свойства
    
    private let fillColor: Color
    private let icon: String?
    private let title: LocalizedStringResource?
    
    // MARK: - Инициализация
    
    init(
        fillColor: Color,
        icon: String? = nil,
        title: LocalizedStringResource? = nil
    ) {
        self.fillColor = fillColor
        self.icon = icon
        self.title = title
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if icon == nil && title == nil {
            EmptyView()
        } else {
            badgeContent
        }
    }
    
    // MARK: - Компоненты
    
    private var badgeContent: some View {
        HStack(alignment: .center, spacing: 4) {
            if let icon {
                Image(systemName: icon)
            }
            if let title {
                Text(title)
            }
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.windowBackground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(minWidth: 36)
        .frame(height: 22)
        .background(fillColor.gradient, in: .capsule)
    }
}

// MARK: - Превью

private struct PreviewContent: View {
    let locale: Locale
    let colorScheme: ColorScheme
    
    var body: some View {
        PreviewWrapper(colorScheme: colorScheme, locale: locale) {
            VStack(spacing: 20) {
                BadgeView(
                    fillColor: Trip.badgeColor,
                    icon: Trip.badgeIcon
                )
                BadgeView(
                    fillColor: EventStatus.ongoing.badgeColor,
                    title: EventStatus.ongoing.localizedResource
                )
                BadgeView(
                    fillColor: ExpenseCategory.activity.badgeColor,
                    icon: ExpenseCategory.activity.badgeIcon,
                    title: ExpenseCategory.activity.localizedResource
                )
            }
        }
    }
}

#Preview("Light - RU") {
    PreviewContent(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    PreviewContent(locale: PreviewLocale.en, colorScheme: .dark)
}
