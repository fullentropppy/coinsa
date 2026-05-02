//
//  LabelView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

/// Кастомизированное представление метки.
struct LabelView: View {
    // MARK: - Вложенные типы
    
    /// Стили отображения метки.
    enum Style {
        /// Метка с иконкой.
        /// - Parameters:
        ///   - title: Локализованный текст метки.
        ///   - icon: Название системной иконки.
        ///   - iconWidth: Фиксированная ширина для иконки (обеспечивает выравнивание).
        case withIcon(title: LocalizedStringResource, icon: String, iconWidth: CGFloat)
        
        /// Метка с текстовым бейджем в формате "бейдж • заголовок".
        /// - Parameters:
        ///   - title: Локализованный текст метки.
        ///   - text: Текст бейджа.
        case withText(title: LocalizedStringResource, text: String)
    }
    
    // MARK: - Свойства
    
    let style: Style
    
    // MARK: - Тело View
    
    var body: some View {
        switch style {
        case .withIcon(let title, let icon, let iconWidth):
            withIconComponent(title: title, icon: icon, iconWidth: iconWidth)
        case .withText(let title, let badge):
            withBadgeComponent(title: title, badge: badge)
        }
    }
    
    // MARK: - Компоненты
    
    private func withIconComponent(
        title: LocalizedStringResource,
        icon: String,
        iconWidth: CGFloat
    ) -> some View {
        HStack(alignment: .center, spacing: 4) {
            Image(systemName: icon)
                .imageScale(.small)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: iconWidth, alignment: .center)
            Text(title)
        }
    }
    
    private func withBadgeComponent(title: LocalizedStringResource, badge: String) -> some View {
        Text("\(badge) • \(title)")
    }
    
}

// MARK: - Превью

private extension LabelView {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    category.makeLabel()
                }
            }
            VStack(alignment: .leading, spacing: 20) {
                ForEach(PaymentMethod.allCases, id: \.self) { method in
                    method.makeLabel()
                }
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    LabelView.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    LabelView.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
