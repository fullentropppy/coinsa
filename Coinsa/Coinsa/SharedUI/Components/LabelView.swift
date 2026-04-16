//
//  LabelView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

struct LabelView: View {
    // MARK: - Свойства
    
    let title: LocalizedStringResource
    let badgeFrameWidth: Double
    let badgeIcon: String?
    let badgeText: String?
    
    // MARK: - Инициализация
    
    init(
        title: LocalizedStringResource,
        badgeFrameWidth: Double,
        badgeIcon: String? = nil,
        badgeText: String? = nil
    ) {
        self.title = title
        self.badgeFrameWidth = badgeFrameWidth
        self.badgeIcon = badgeIcon
        self.badgeText = badgeText
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if badgeIcon == nil && badgeText == nil {
            EmptyView()
        } else {
            labelContent
        }
    }
    
    // MARK: - Компоненты
    
    private var labelContent: some View {
        HStack(alignment: .center, spacing: 4) {
            Group {
                if let badgeIcon {
                    Image(systemName: badgeIcon)
                        .imageScale(.small)
                } else if let badgeText {
                    Text(badgeText)
                        .font(.body.monospaced().weight(.semibold))
                }
            }
            .foregroundStyle(.secondary)
            .frame(width: badgeFrameWidth)
            Text(title)
        }
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
