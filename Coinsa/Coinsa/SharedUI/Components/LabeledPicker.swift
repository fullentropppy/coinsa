//
//  LabeledPicker.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.04.2026.
//

import SwiftUI

/// Кастомизированный пикер с заголовком, работающий как навигационная ссылка в списке.
struct LabeledPicker<SelectionValue: Hashable, Content: View>: View {
    // MARK: - Свойства
    
    private let title: LocalizedStringResource?
    private let selection: Binding<SelectionValue>
    private let options: [SelectionValue]
    private let isDisabled: Bool
    @ViewBuilder private let content: (SelectionValue) -> Content

    // MARK: - Инициализация
    
    /// Создает пикер с заголовком.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - options: Массив доступных опций.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Замыкание для построения представления каждой опции.
    init(
        title: LocalizedStringResource? = nil,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        isDisabled: Bool = false,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.title = title
        self.selection = selection
        self.options = options
        self.isDisabled = isDisabled
        self.content = content
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if isDisabled {
            disabledContent
        } else {
            enabledContent
        }
    }
    
    // MARK: - Компоненты
    
    private var disabledContent: some View {
        LabeledContent {
            content(selection.wrappedValue)
        } label: {
            if let title {
                Text(title)
            }
        }
    }
    
    private var enabledContent: some View {
        HStack {
            Picker(selection: selection) {
                ForEach(options, id: \.self) { option in
                    content(option)
                        .tag(option)
                }
            } label: {
                if let title {
                    Text(title)
                }
            }
            .pickerStyle(.navigationLink)
            .navigationLinkIndicatorVisibility(.hidden)
            
            Image(systemName: "chevron.right")
                .imageScale(.small)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
                .frame(width: 16)
        }
    }
}

// MARK: - Превью

#Preview {
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
            LabeledPicker(
                title: .expenseCategory,
                selection: $selectedCategory,
                options: ExpenseCategory.allCases,
                isDisabled: true
            ) { category in
                category.makeLabel()
            }
        }
    }
}
