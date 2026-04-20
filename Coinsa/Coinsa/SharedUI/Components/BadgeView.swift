//
//  BadgeView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

struct BadgeView: View {
    // MARK: - Вложенные типы
    
    enum Style {
        case icon(icon: String, fill: Color)
        case title(title: LocalizedStringResource, fill: Color)
        case combined(icon: String, badge: LocalizedStringResource, fill: Color)
    }
    
    // MARK: - Свойства
    
    private let fill: Color
    private let icon: String?
    private let title: LocalizedStringResource?
    
    // MARK: - Инициализация
    
    init(style: Style) {
        switch style {
        case .icon(let icon, let fill):
            self.fill = fill
            self.icon = icon
            self.title = nil
        case .title(let text, let fill):
            self.fill = fill
            self.icon = nil
            self.title = text
        case .combined(let icon, let text, let fill):
            self.fill = fill
            self.icon = icon
            self.title = text
        }
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
        .background(fill.gradient, in: .capsule)
    }
    
    private func iconComponent(icon: String) -> some View {
        Image(systemName: icon)
    }
    
    private func badgeComponent(badge: LocalizedStringResource) -> some View {
        Text(badge)
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
