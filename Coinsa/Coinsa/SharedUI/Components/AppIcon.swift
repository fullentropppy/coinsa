//
//  AppIcon.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import SwiftUI

/// Системная иконка с оформлением по роли в интерфейсе.
struct AppIcon: View {
    // MARK: - Вложенные типы

    enum Style: CaseIterable {
        case compact
        case formLabel
        /// Компактные сведения с шрифтом и цветом родительской метки.
        case inlineMetadata
        case metadata
        case inputAccessory
        case navigationLabel
        case navigationIndicator
        case selectionIndicator
    }

    // MARK: - Свойства

    let name: String
    let style: Style

    // MARK: - Инициализация

    /// Создает иконку, наследующую размер текста, если роль не задает собственный.
    /// - Parameters:
    ///   - name: Имя символа из `AppSymbols` или доменного UI-представления.
    ///   - style: Роль, определяющая масштаб, насыщенность, цвет и выравнивание.
    init(_ name: String, style: Style = .compact) {
        self.name = name
        self.style = style
    }

    // MARK: - Тело View

    @ViewBuilder
    var body: some View {
        switch style {
        case .compact:
            compactImage
        case .formLabel:
            compactImage
                .foregroundStyle(.secondary)
                .frame(width: ViewLayout.Label.formIconWidth)
        case .inlineMetadata:
            metadataImage
        case .metadata:
            metadataImage
                .appTextStyle(.secondaryFootnote)
        case .inputAccessory:
            compactImage
                .foregroundStyle(.secondary)
                .frame(width: ViewLayout.Label.inputAccessoryWidth)
        case .navigationLabel:
            compactImage
                .font(.subheadline)
        case .navigationIndicator:
            compactImage
                .foregroundStyle(.accent)
                .frame(width: ViewLayout.Label.inputAccessoryWidth)
        case .selectionIndicator:
            compactImage
                .foregroundStyle(.tint)
        }
    }

    // MARK: - Компоненты

    private var compactImage: some View {
        Image(systemName: name)
            .imageScale(.small)
            .fontWeight(.semibold)
    }

    private var metadataImage: some View {
        Image(systemName: name)
            .imageScale(.small)
            .fontWeight(.medium)
    }
}

// MARK: - Превью

#Preview("Icon roles") {
    VStack(spacing: 20) {
        ForEach(AppIcon.Style.allCases, id: \.self) { style in
            HStack {
                AppIcon(AppSymbols.calendar, style: style)
                AppIcon(AppSymbols.ellipsisBubble, style: style)
                AppIcon(AppSymbols.checkmark, style: style)
            }
        }
    }
    .padding()
}

#Preview("Large text, dark") {
    HStack(spacing: 20) {
        AppIcon(AppSymbols.calendar, style: .formLabel)
        AppIcon(AppSymbols.percent, style: .inputAccessory)
        AppIcon(AppSymbols.chevronRight, style: .navigationIndicator)
        AppIcon(AppSymbols.checkmark, style: .selectionIndicator)
    }
    .dynamicTypeSize(.xxxLarge)
    .preferredColorScheme(.dark)
    .padding()
}
