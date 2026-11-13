//
//  Badge.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 30.03.2026.
//

import SwiftUI

/// Представление бейджа с иконкой, текстом или комбинированным содержимым.
struct Badge: View {
    // MARK: - Константы

    private enum Layout {
        /// Боковые отступы содержимого бейджа.
        static let horizontalInset: CGFloat = 8
        /// Вертикальные отступы содержимого бейджа.
        static let verticalInset: CGFloat = 4
        /// Минимальная ширина бейджа, в том числе только с иконкой.
        static let minWidth: CGFloat = 36
        /// Единая высота бейджей в строках и заголовках.
        static let height: CGFloat = 22
    }

    // MARK: - Вложенные типы
    
    /// Стили бейджа, определяющие его содержимое и цвет.
    enum Style {
        /// Только иконка.
        /// - Parameters:
        ///   - icon: Название системной иконки.
        ///   - fill: Цвет заливки бейджа.
        case icon(icon: String, fill: Color)
        
        /// Только текст.
        /// - Parameters:
        ///   - title: Локализованный текст.
        ///   - fill: Цвет заливки бейджа.
        case title(title: LocalizedStringResource, fill: Color)
        
        /// Иконка и текст.
        /// - Parameters:
        ///   - icon: Название системной иконки.
        ///   - badge: Локализованный текст.
        ///   - fill: Цвет заливки бейджа.
        case combined(icon: String, badge: LocalizedStringResource, fill: Color)
    }
    
    // MARK: - Свойства
    
    private let fill: Color
    private let icon: String?
    private let title: LocalizedStringResource?
    
    // MARK: - Инициализация
    
    /// Создает бейдж с указанным стилем.
    /// - Parameter style: Стиль бейджа.
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
        HStack(alignment: .center, spacing: ViewLayout.Label.iconSpacing) {
            if let icon {
                Image(systemName: icon)
            }
            if let title {
                Text(title)
            }
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.windowBackground)
        .padding(.horizontal, Layout.horizontalInset)
        .padding(.vertical, Layout.verticalInset)
        .frame(minWidth: Layout.minWidth)
        .frame(height: Layout.height)
        .background(fill.gradient, in: .capsule)
    }
}

// MARK: - Превью

#Preview {
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
}
