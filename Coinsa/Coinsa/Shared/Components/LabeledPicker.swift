//
//  LabeledPicker.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.04.2026.
//

import SwiftUI

struct LabeledPicker<SelectionValue: Hashable, Content: View>: View {
    // MARK: - Свойства
    
    let title: LocalizedStringResource
    let selection: Binding<SelectionValue>
    let options: [SelectionValue]
    @ViewBuilder let content: (SelectionValue) -> Content
    
    // MARK: - Инициализация
    
    init(
        title: LocalizedStringResource,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.title = title
        self.selection = selection
        self.options = options
        self.content = content
    }
    
    // MARK: - Тело View
    
    var body: some View {
        HStack {
            Picker(title, selection: selection) {
                ForEach(options, id: \.self) { option in
                    content(option)
                        .tag(option)
                }
            }
            .pickerStyle(.navigationLink)
            .navigationLinkIndicatorVisibility(.hidden)
            
            Image(systemName: "chevron.right")
                .imageScale(.small)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
        }
    }
}

// MARK: - Превью

#Preview("Light - RU") {
    @Previewable @State var selectedCategory = ExpenseCategory.food
    
    NavigationStack {
        List {
            LabeledPicker(
                title: .expenseCategory,
                selection: $selectedCategory,
                options: ExpenseCategory.allCases
            ) { category in
                ExpenseCategoryLabel(category: category)
            }
        }
    }
    .environment(\.locale, PreviewLocale.ru)
    .preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    @Previewable @State var selectedCategory = ExpenseCategory.food
    
    NavigationStack {
        List {
            LabeledPicker(
                title: .expenseCategory,
                selection: $selectedCategory,
                options: ExpenseCategory.allCases
            ) { category in
                ExpenseCategoryLabel(category: category)
            }
        }
    }
    .environment(\.locale, PreviewLocale.en)
    .preferredColorScheme(.dark)
}
