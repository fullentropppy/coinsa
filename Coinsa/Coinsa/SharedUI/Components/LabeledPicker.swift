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

/// Пикер с заголовком и выбором значения в модальном списке.
struct LabeledPicker<SelectionValue: Hashable, Content: View, CurrentValueLabel: View>: View {
    // MARK: - Состояние

    @State private var isSheetPresented = false

    // MARK: - Свойства
    
    private let title: LocalizedStringResource?
    private let selection: Binding<SelectionValue>
    private let sections: [PickerSection<SelectionValue>]
    private let isDisabled: Bool
    
    @ViewBuilder private let content: (SelectionValue) -> Content
    @ViewBuilder private let currentValueLabel: (SelectionValue) -> CurrentValueLabel
    
    // MARK: - Инициализация
    
    /// Создает пикер с заголовком, опциями в единой секции и кастомным видом текущего значения.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - options: Массив доступных опций.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Замыкание для построения представления каждой опции в списке выбора.
    ///   - currentValueLabel: Замыкание для построения представления текущего значения в строке списка.
    init(
        title: LocalizedStringResource? = nil,
        selection: Binding<SelectionValue>,
        options: [SelectionValue],
        isDisabled: Bool = false,
        @ViewBuilder content: @escaping (SelectionValue) -> Content,
        @ViewBuilder currentValueLabel: @escaping (SelectionValue) -> CurrentValueLabel
    ) {
        self.init(
            title: title,
            selection: selection,
            sections: [PickerSection(title: nil, options: options)],
            isDisabled: isDisabled,
            content: content,
            currentValueLabel: currentValueLabel
        )
    }
    
    /// Создает пикер с заголовком, опциями в указанных секциях и кастомным видом текущего значения.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - sections: Массив секций с опциями.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Замыкание для построения представления каждой опции в списке выбора.
    ///   - currentValueLabel: Замыкание для построения представления текущего значения в строке списка.
    init(
        title: LocalizedStringResource? = nil,
        selection: Binding<SelectionValue>,
        sections: [PickerSection<SelectionValue>],
        isDisabled: Bool = false,
        @ViewBuilder content: @escaping (SelectionValue) -> Content,
        @ViewBuilder currentValueLabel: @escaping (SelectionValue) -> CurrentValueLabel
    ) {
        self.title = title
        self.selection = selection
        self.sections = sections
        self.isDisabled = isDisabled
        self.content = content
        self.currentValueLabel = currentValueLabel
    }
    
    /// Создает пикер с заголовком и опциями в единой секции. В качестве `currentValueLabel` используется `content`.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - options: Массив доступных опций.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Замыкание для построения представления каждой опции в списке выбора.
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
            options: options,
            isDisabled: isDisabled,
            content: content,
            currentValueLabel: content as! (SelectionValue) -> CurrentValueLabel
        )
    }
    
    /// Создает пикер с заголовком и опциями в указанных секциях. В качестве `currentValueLabel` используется `content`.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - sections: Массив секций с опциями.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Замыкание для построения представления каждой опции в списке выбора.
    init(
        title: LocalizedStringResource? = nil,
        selection: Binding<SelectionValue>,
        sections: [PickerSection<SelectionValue>],
        isDisabled: Bool = false,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.init(
            title: title,
            selection: selection,
            sections: sections,
            isDisabled: isDisabled,
            content: content,
            currentValueLabel: content as! (SelectionValue) -> CurrentValueLabel
        )
    }
    
    // MARK: - Тело View
    
    var body: some View {
        if isDisabled {
            selectionLabel
        } else {
            enabledContent
        }
    }
    
    // MARK: - Компоненты
    
    private var selectionLabel: some View {
        LabeledContent {
            HStack(spacing: ViewLayout.Label.pickerIndicatorSpacing) {
                currentValueLabel(selection.wrappedValue)
                if !isDisabled {
                    AppIcon(AppSymbols.chevronRight, style: .navigationIndicator)
                }
            }
        } label: {
            if let title {
                Text(title)
            }
        }
    }
    
    private var enabledContent: some View {
        Button {
            isSheetPresented = true
        } label: {
            selectionLabel
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $isSheetPresented) {
            NavigationStack {
                optionsList
                    .navigationTitle(title ?? "")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            ToolbarButton.close {
                                isSheetPresented = false
                            }
                        }
                    }
            }
        }
    }

    private var optionsList: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.options, id: \.self) { option in
                        Button {
                            selection.wrappedValue = option
                            isSheetPresented = false
                        } label: {
                            HStack {
                                content(option)
                                Spacer()
                                if option == selection.wrappedValue {
                                    AppIcon(AppSymbols.checkmark, style: .selectionIndicator)
                                }
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    if let sectionTitle = section.title {
                        Text(sectionTitle)
                    }
                }
            }
        }
        .environment(\.isScrollEnabled, true)
    }
}

// MARK: - Удобные инициализаторы без currentValueLabel

extension LabeledPicker where CurrentValueLabel == Content {
    /// Создает пикер с заголовком и опциями в единой секции.
    /// В качестве `currentValueLabel` используется `content`.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - options: Массив доступных опций.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Представление опции и текущего значения.
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
            options: options,
            isDisabled: isDisabled,
            content: content,
            currentValueLabel: content
        )
    }
    
    /// Создает пикер с заголовком и опциями в указанных секциях.
    /// В качестве `currentValueLabel` используется `content`.
    /// - Parameters:
    ///   - title: Заголовок пикера (по умолчанию `nil`).
    ///   - selection: Привязка к выбранному значению.
    ///   - sections: Массив секций с опциями.
    ///   - isDisabled: Флаг блокировки (по умолчанию `false`).
    ///   - content: Представление опции и текущего значения.
    init(
        title: LocalizedStringResource? = nil,
        selection: Binding<SelectionValue>,
        sections: [PickerSection<SelectionValue>],
        isDisabled: Bool = false,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.init(
            title: title,
            selection: selection,
            sections: sections,
            isDisabled: isDisabled,
            content: content,
            currentValueLabel: content
        )
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
                content: { category in
                    category.makeLabel()
                },
                currentValueLabel: { category in
                    Image(systemName: category.primaryIcon)
                }
            )
            
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
