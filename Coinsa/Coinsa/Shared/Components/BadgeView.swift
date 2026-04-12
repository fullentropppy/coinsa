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
        .foregroundStyle(.windowBackground)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(minWidth: 36)
        .frame(height: 22)
        .background(fillColor.gradient, in: .capsule)
    }
}

// MARK: - Previews

private extension BadgeView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 40) {
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
            }
            VStack(spacing: 20) {
                BadgeView(
                    fillColor: EventStatus.upcoming.badgeColor,
                    title: EventStatus.upcoming.localizedResource
                )
                BadgeView(
                    fillColor: EventStatus.ongoing.badgeColor,
                    title: EventStatus.ongoing.localizedResource
                )
                BadgeView(
                    fillColor: EventStatus.completed.badgeColor,
                    title: EventStatus.completed.localizedResource
                )
            }
            VStack(spacing: 20) {
                BadgeView(
                    fillColor: ExpenseCategory.food.badgeColor,
                    icon: ExpenseCategory.food.badgeIcon,
                    title: ExpenseCategory.food.localizedResource
                )
                BadgeView(
                    fillColor: ExpenseCategory.transport.badgeColor,
                    icon: ExpenseCategory.transport.badgeIcon,
                    title: ExpenseCategory.transport.localizedResource
                )
                BadgeView(
                    fillColor: ExpenseCategory.activity.badgeColor,
                    icon: ExpenseCategory.activity.badgeIcon,
                    title: ExpenseCategory.activity.localizedResource
                )
                BadgeView(
                    fillColor: ExpenseCategory.shopping.badgeColor,
                    icon: ExpenseCategory.shopping.badgeIcon,
                    title: ExpenseCategory.shopping.localizedResource
                )
                BadgeView(
                    fillColor: ExpenseCategory.medicine.badgeColor,
                    icon: ExpenseCategory.medicine.badgeIcon,
                    title: ExpenseCategory.medicine.localizedResource
                )
                BadgeView(
                    fillColor: ExpenseCategory.other.badgeColor,
                    icon: ExpenseCategory.other.badgeIcon,
                    title: ExpenseCategory.other.localizedResource
                )
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    BadgeView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    BadgeView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
