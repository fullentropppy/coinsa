//
//  LabeledPicker.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.04.2026.
//

import SwiftUI

/// Секция опций пикера.
struct PickerSection<Value: Hashable>: Identifiable {
    // MARK: - Свойства
    
    let id = UUID()
    let title: LocalizedStringResource?
    let options: [Value]
    
    // MARK: - Инициализация
    
    /// Создает секцию опций пикера.
    /// - Parameters:
    ///   - title: Заголовок секции пикера (по умолчанию `nil`).
    ///   - options: Массив доступных опций.
    init(title: LocalizedStringResource? = nil, options: [Value]) {
        self.title = title
        self.options = options
    }
}

/// Кастомизированный пикер с заголовком, работающий как навигационная ссылка в списке.
struct LabeledPicker<SelectionValue: Hashable, Content: View>: View {
    // MARK: - Свойства
    
    private let title: LocalizedStringResource?
    private let selection: Binding<SelectionValue>
    private let sections: [PickerSection<SelectionValue>]
    private let isDisabled: Bool
    @ViewBuilder private let content: (SelectionValue) -> Content

    // MARK: - Инициализация
    
    /// Создает пикер с заголовком с опциями в единой секции.
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
        self.init(
            title: title,
            selection: selection,
            sections: [PickerSection(title: nil, options: options)],
            isDisabled: isDisabled,
            content: content
        )
    }
    
    /// Создает пикер с заголовком с опциями в указанных секциях.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - sections: Массив секций с опциями.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Замыкание для построения представления каждой опции.
    init(
        title: LocalizedStringResource? = nil,
        selection: Binding<SelectionValue>,
        sections: [PickerSection<SelectionValue>],
        isDisabled: Bool = false,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.title = title
        self.selection = selection
        self.sections = sections
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
                ForEach(sections) { section in
                    Section {
                        ForEach(section.options, id: \.self) { option in
                            content(option).tag(option)
                        }
                    } header: {
                        if let sectionTitle = section.title {
                            Text(sectionTitle)
                        }
                    }
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
