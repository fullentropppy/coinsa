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

private extension BadgeView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                Trip.makeBadge()
                Location.makeBadge()
                Expense.makeBadge()
            }
            VStack(spacing: 20) {
                ForEach(EventStatus.allCases, id: \.self) { status in
                    status.makeBadge()
                }
            }
            VStack(spacing: 20) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    category.makeBadge()
                }
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
