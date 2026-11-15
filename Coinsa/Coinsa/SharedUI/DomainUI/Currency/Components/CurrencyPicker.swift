//
//  CurrencyPicker.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.11.2026.
//

import SwiftUI

/// Пикер валют с поиском по коду и локализованному названию.
struct CurrencyPicker<CurrentValueLabel: View>: View {
    // MARK: - Окружение

    @Environment(\.locale) private var locale

    // MARK: - Состояние

    @State private var isSheetPresented = false

    // MARK: - Свойства

    private let title: LocalizedStringResource?
    private let selection: Binding<Currency>
    private let sections: [PickerSection<Currency>]
    private let isDisabled: Bool
    @ViewBuilder private let currentValueLabel: (Currency) -> CurrentValueLabel

    // MARK: - Инициализация

    /// Создает пикер валют с готовым представлением опций и поиском.
    /// - Parameters:
    ///   - title: Заголовок пикера.
    ///   - selection: Привязка к выбранной валюте.
    ///   - sections: Секции валют; по умолчанию все валюты отсортированы по названию.
    ///   - isDisabled: Флаг блокировки выбора.
    ///   - currentValueLabel: Представление текущей валюты в строке формы.
    init(
        title: LocalizedStringResource? = nil,
        selection: Binding<Currency>,
        sections: [PickerSection<Currency>] = [PickerSection(options: Currency.allCasesSortedByName)],
        isDisabled: Bool = false,
        @ViewBuilder currentValueLabel: @escaping (Currency) -> CurrentValueLabel
    ) {
        self.title = title
        self.selection = selection
        self.sections = sections
        self.isDisabled = isDisabled
        self.currentValueLabel = currentValueLabel
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
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.semibold)
                        .foregroundStyle(.accent)
                        .frame(width: ViewLayout.Label.inputAccessoryWidth)
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
                searchableContent
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

    private var searchableContent: some View {
        SearchablePickerView(
            title: title,
            selection: selection,
            sections: sections,
            searchText: searchText
        ) { currency in
            currency.makeLabel()
        }
    }

    // MARK: - Поиск

    private func searchText(for currency: Currency) -> String {
        var name = currency.localizedResource
        name.locale = locale
        return "\(currency.code) \(String(localized: name))"
    }
}

// MARK: - Превью

#Preview("Editing") {
    @Previewable @State var selection = Currency.rub

    NavigationStack {
        Form {
            CurrencyPicker(
                title: .expenseCurrency,
                selection: $selection,
                sections: Currency.pickerSections(homeCurrency: .rub, locationCurrency: .thb)
            ) { currency in
                CurrencyCodeText.standard(currency)
            }
        }
    }
}

#Preview("Creating") {
    @Previewable @State var selection = Currency.usd

    NavigationStack {
        Form {
            CurrencyPicker(title: .tripCurrency, selection: $selection) { currency in
                CurrencyCodeText.standard(currency)
            }
        }
    }
}

#Preview("Converter") {
    @Previewable @State var selection = Currency.usd

    NavigationStack {
        Form {
            CurrencyPicker(
                title: .converterFromCurrenency,
                selection: $selection
            ) { currency in
                Text(currency.localizedResource)
            }
        }
    }
}
