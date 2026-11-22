//
//  ItemLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

/// Кастомизированное представление метки.
struct ItemLabel: View {
    // MARK: - Вложенные типы
    
    /// Стили отображения метки.
    enum Style {
        /// Метка с иконкой.
        /// - Parameters:
        ///   - title: Локализованный текст метки.
        ///   - icon: Название системной иконки.
        case withIcon(title: LocalizedStringResource, icon: String)
        
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
        case .withIcon(let title, let icon):
            withIconComponent(title: title, icon: icon)
        case .withText(let title, let badge):
            withBadgeComponent(title: title, badge: badge)
        }
    }
    
    // MARK: - Компоненты
    
    private func withIconComponent(
        title: LocalizedStringResource,
        icon: String
    ) -> some View {
        HStack(alignment: .center, spacing: ViewLayout.Label.iconSpacing) {
            AppIcon(icon, style: .formLabel)
            Text(title)
        }
    }
    
    private func withBadgeComponent(title: LocalizedStringResource, badge: String) -> some View {
        Text("\(badge) • \(title)")
    }
    
}

// MARK: - Превью

#Preview {
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
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        Currency.defaultValue.makeLabel()
        Currency.jpy.makeLabel()
    }
    .padding()
}
