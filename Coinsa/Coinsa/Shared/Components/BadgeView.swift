//
//  BadgeView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

struct BadgeView: View {
    // MARK: - Stored Properties
    
    private let fillColor: Color
    private let icon: String?
    private let title: LocalizedStringResource?
    
    // MARK: - Initialization
    
    init(
        fillColor: Color,
        icon: String? = nil,
        title: LocalizedStringResource? = nil
    ) {
        self.fillColor = fillColor
        self.icon = icon
        self.title = title
    }
    
    // MARK: - Body
    
    var body: some View {
        if icon == nil && title == nil {
            EmptyView()
        } else {
            badgeContent
        }
    }
    
    // MARK: - Components
    
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
        .foregroundStyle(.background)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(minWidth: 36)
        .frame(height: 22)
        .background(fillColor, in: .capsule)
    }
}

// MARK: - Previews

private extension BadgeView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 40) {
            BadgeView(
                fillColor: Trip.badgeColor,
                icon: Trip.badgeIcon
            )
            BadgeView(
                fillColor: ExpenseCategory.food.badgeColor,
                icon: ExpenseCategory.food.badgeIcon,
                title: ExpenseCategory.food.localized
            )
            BadgeView(
                fillColor: EventStatus.upcoming.color,
                title: EventStatus.upcoming.localized
            )
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    BadgeView.makePreview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    BadgeView.makePreview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
