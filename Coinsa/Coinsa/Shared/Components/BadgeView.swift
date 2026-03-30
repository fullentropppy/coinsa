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
    private let title: LocalizedStringKey?
    
    // MARK: - Initialization
    
    init(
        fillColor: Color,
        icon: String? = nil,
        title: LocalizedStringKey? = nil
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
            content
        }
    }
    
    // MARK: - Components
    
    private var content: some View {
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
        .frame(height: 22)
        .background(fillColor, in: .capsule)
    }
}

// MARK: - Previews

private extension BadgeView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            BadgeView(
                fillColor: Trip.badgeColor,
                icon: Trip.badgeIcon
            )
            BadgeView(
                fillColor: Location.badgeColor,
                icon: Location.badgeIcon
            )
            BadgeView(
                fillColor: Expense.badgeColor,
                icon: Expense.badgeIcon
            )
            BadgeView(
                fillColor: ExpenseCategory.food.badgeColor,
                icon: ExpenseCategory.food.badgeIcon,
                title: ExpenseCategory.food.localizedKey
            )
            BadgeView(
                fillColor: ExpenseCategory.shopping.badgeColor,
                icon: ExpenseCategory.shopping.badgeIcon,
                title: ExpenseCategory.shopping.localizedKey
            )
            BadgeView(
                fillColor: ExpenseCategory.other.badgeColor,
                icon: ExpenseCategory.other.badgeIcon,
                title: ExpenseCategory.other.localizedKey
            )
            BadgeView(
                fillColor: EventStatus.upcoming.color,
                title: EventStatus.upcoming.localizedKey
            )
            BadgeView(
                fillColor: EventStatus.ongoing.color,
                title: EventStatus.ongoing.localizedKey
            )
            BadgeView(
                fillColor: EventStatus.completed.color,
                title: EventStatus.completed.localizedKey
            )
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    BadgeView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    BadgeView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
