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
            Text(category.localizedResource)
        }
    }
}

// MARK: - Previews

private extension ExpenseCategoryLabel {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
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
    ExpenseCategoryLabel.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    ExpenseCategoryLabel.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
