//
//  DetailNavigationButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 26.11.2026.
//

import SwiftUI

/// Кнопка перехода к связанному экрану под сводкой.
struct DetailNavigationButton: View {
    // MARK: - Константы

    private enum Layout {
        /// Вертикальные отступы содержимого кнопки.
        static let verticalInset: CGFloat = 4
    }

    // MARK: - Свойства

    private let icon: String
    private let title: LocalizedStringResource
    private let action: () -> Void

    // MARK: - Инициализация

    /// Создает кнопку, оставляя управление навигацией вызывающему экрану.
    /// - Parameters:
    ///   - icon: Иконка назначения из общего каталога или UI-представления сущности.
    ///   - title: Локализованная подпись назначения.
    ///   - action: Действие перехода или возврата к уже открытому экрану.
    init(icon: String, title: LocalizedStringResource, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.action = action
    }

    // MARK: - Тело View

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                AppIcon(icon, style: .navigationLabel)
                Text(title)
            }
            .font(.footnote.weight(.medium))
            .padding(.vertical, Layout.verticalInset)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(.glass)
        .foregroundStyle(Color.primary)
    }
}

// MARK: - Предопределенные варианты

extension DetailNavigationButton {
    /// Кнопка перехода к поездке.
    /// - Parameter action: Действие перехода или возврата к поездке.
    /// - Returns: Настроенная кнопка.
    static func trip(action: @escaping () -> Void) -> some View {
        DetailNavigationButton(icon: Trip.primaryIcon, title: .tripNavigationParent, action: action)
    }

    /// Кнопка перехода к локации.
    /// - Parameter action: Действие перехода к локации.
    /// - Returns: Настроенная кнопка.
    static func location(action: @escaping () -> Void) -> some View {
        DetailNavigationButton(icon: Location.primaryIcon, title: .locationNavigationParent, action: action)
    }

    /// Кнопка перехода к аналитике.
    /// - Parameter action: Действие перехода к аналитике.
    /// - Returns: Настроенная кнопка.
    static func analytics(action: @escaping () -> Void) -> some View {
        DetailNavigationButton(icon: AppSymbols.chartXyaxisLine, title: .analytics, action: action)
    }
}

// MARK: - Превью

#Preview {
    List {
        HStack {
            DetailNavigationButton(icon: Expense.primaryIcon, title: .tripGeneralExpenses) {}
            DetailNavigationButton.analytics {}
        }
        HStack {
            DetailNavigationButton.trip {}
            DetailNavigationButton.location {}
        }
    }
}
