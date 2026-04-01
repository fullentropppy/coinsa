//
//  ExpenseCategoryLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 14.03.2026.
//

import SwiftUI

struct ExpenseCategoryLabel: View {
    // MARK: - Stored Properties

    var category: ExpenseCategory

    // MARK: - Body
    
    var body: some View {
        HStack {
            Image(systemName: category.labelIcon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(category.localized)
        }
    }
}

// MARK: - Previews

private extension ExpenseCategoryLabel {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(ExpenseCategory.allCases, id: \.id) { (category: ExpenseCategory) in
                ExpenseCategoryLabel(category: category)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ExpenseCategoryLabel.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseCategoryLabel.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
