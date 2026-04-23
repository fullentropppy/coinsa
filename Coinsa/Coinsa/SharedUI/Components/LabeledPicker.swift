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
    let disabled: Bool
    @ViewBuilder let content: (SelectionValue) -> Content
    
    // MARK: - Инициализация
    
    init(
        title: LocalizedStringResource,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        disabled: Bool = false,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.title = title
        self.selection = selection
        self.options = options
        self.disabled = disabled
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
            .disabled(disabled)
            
            Image(systemName: "chevron.right")
                .imageScale(.small)
                .fontWeight(.semibold)
                .foregroundStyle(disabled ? Color.secondary.opacity(0.85) : Color.accent)
                .frame(width: 16)
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
                category.makeLabel()
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
                category.makeLabel()
            }
        }
    }
    .environment(\.locale, PreviewLocale.en)
    .preferredColorScheme(.dark)
}
