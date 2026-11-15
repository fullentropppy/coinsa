//
//  SearchablePickerView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI

/// Экран выбора значения с системным поиском в нижней панели.
struct SearchablePickerView<SelectionValue: Hashable, Content: View>: View {
    // MARK: - Окружение

    @Environment(\.dismiss) private var dismiss

    // MARK: - Свойства

    private let title: LocalizedStringResource?
    @Binding private var selection: SelectionValue
    private let sections: [PickerSection<SelectionValue>]
    private let searchText: (SelectionValue) -> String
    @ViewBuilder private let content: (SelectionValue) -> Content

    @State private var query = ""

    // MARK: - Инициализация

    /// Создает экран выбора с поиском по текстовому представлению опций.
    /// - Parameters:
    ///   - title: Заголовок экрана.
    ///   - selection: Привязка к выбранному значению.
    ///   - sections: Секции в исходном порядке приоритета.
    ///   - searchText: Текст опции для фильтрации.
    ///   - content: Представление опции в списке.
    init(
        title: LocalizedStringResource?,
        selection: Binding<SelectionValue>,
        sections: [PickerSection<SelectionValue>],
        searchText: @escaping (SelectionValue) -> String,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.title = title
        self._selection = selection
        self.sections = sections
        self.searchText = searchText
        self.content = content
    }

    // MARK: - Тело View

    var body: some View {
        List {
            ForEach(sections) { section in
                let options = filteredOptions(in: section)

                if !options.isEmpty {
                    Section {
                        ForEach(options, id: \.self) { option in
                            Button {
                                selection = option
                                dismiss()
                            } label: {
                                HStack {
                                    content(option)
                                    Spacer()
                                    if option == selection {
                                        Image(systemName: "checkmark")
                                            .imageScale(.small)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.tint)
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
        }
        .environment(\.isScrollEnabled, true)
        .overlay {
            if sections.allSatisfy({ filteredOptions(in: $0).isEmpty }) {
                ContentUnavailableView.search(text: query)
            }
        }
        .navigationTitle(title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $query)
        .toolbar(.visible, for: .bottomBar)
        .toolbar {
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
        }
    }

    // MARK: - Фильтрация

    private func filteredOptions(in section: PickerSection<SelectionValue>) -> [SelectionValue] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return section.options }
        return section.options.filter { searchText($0).localizedStandardContains(trimmedQuery) }
    }
}

// MARK: - Превью

#Preview("With Prioritized") {
    @Previewable @State var selection = Currency.rub

    NavigationStack {
        SearchablePickerView(
            title: .expenseCurrency,
            selection: $selection,
            sections: Currency.pickerSections(homeCurrency: .rub, locationCurrency: .thb),
            searchText: { "\($0.code) \(String(localized: $0.localizedResource))" }
        ) { currency in
            currency.makeLabel()
        }
    }
}

#Preview("All") {
    @Previewable @State var selection = Currency.usd

    NavigationStack {
        SearchablePickerView(
            title: .tripHomeCurrency,
            selection: $selection,
            sections: [PickerSection(options: Currency.allCasesSortedByName)],
            searchText: { "\($0.code) \(String(localized: $0.localizedResource))" }
        ) { currency in
            currency.makeLabel()
        }
    }
}
