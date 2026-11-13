//
//  TodayQuickExpensesView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import SwiftUI

/// Сетка быстрых категорий и популярных подкатегорий трат.
struct TodayQuickExpensesView: View {
    // MARK: - Константы

    /// Размеры сетки, отступы и параметры оформления быстрых кнопок.
    private enum Layout {
        /// Непрозрачность белой подложки быстрых кнопок в светлой теме.
        static let lightButtonTintOpacity: Double = 0.1
        /// Непрозрачность черной подложки быстрых кнопок в темной теме.
        static let darkButtonTintOpacity: Double = 0.2
        /// Минимальная ширина колонки быстрых трат.
        static let quickExpenseMinWidth: CGFloat = 140
        /// Интервал между быстрыми кнопками и их рядами.
        static let quickExpenseSpacing: CGFloat = 8
        /// Отступ сетки быстрых трат от границ строки списка.
        static let quickExpenseGridInset: CGFloat = 4
        /// Боковые отступы заголовков секций с обнуленными listRowInsets.
        static let sectionHeaderHorizontalInset: CGFloat = 16
        /// Вертикальные отступы заголовков секций с обнуленными listRowInsets.
        static let sectionHeaderVerticalInset: CGFloat = 8
        /// Размер иконок быстрых категорий и подкатегорий.
        static let quickExpenseIconSize: CGFloat = 20
        /// Радиус цветного свечения иконок быстрых трат.
        static let quickExpenseShadowRadius: CGFloat = 12
        /// Боковые отступы содержимого быстрой кнопки категории.
        static let quickExpenseHorizontalInset: CGFloat = 8
        /// Вертикальные отступы содержимого быстрых кнопок.
        static let quickExpenseVerticalInset: CGFloat = 4
    }

    // MARK: - Окружение

    @Environment(\.haptics) private var haptics
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Свойства

    let subcategories: [ExpenseSubcategory]
    let onSelect: (ExpenseCategory, ExpenseSubcategory?) -> Void

    // MARK: - Визуальный стиль

    private var buttonTint: Color {
        colorScheme == .light ? .white.opacity(Layout.lightButtonTintOpacity) : .black.opacity(Layout.darkButtonTintOpacity)
    }

    // MARK: - Инициализация

    /// Создает сетку быстрых категорий и подкатегорий трат.
    /// - Parameters:
    ///   - subcategories: Подкатегории для дополнительных кнопок в заданном порядке.
    ///   - onSelect: Действие выбора категории и необязательной подкатегории; для кнопки категории подкатегория равна `nil`.
    init(
        subcategories: [ExpenseSubcategory],
        onSelect: @escaping (ExpenseCategory, ExpenseSubcategory?) -> Void
    ) {
        self.subcategories = subcategories
        self.onSelect = onSelect
    }

    // MARK: - Тело View

    var body: some View {
        Section {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: Layout.quickExpenseMinWidth), spacing: Layout.quickExpenseSpacing)],
                spacing: Layout.quickExpenseSpacing
            ) {
                ForEach(ExpenseCategory.allCases, id: \.id) { category in
                    quickExpenseButton(category: category)
                }
                HStack(spacing: Layout.quickExpenseSpacing) {
                    ForEach(subcategories) { subcategory in
                        quickExpenseButton(subcategory: subcategory)
                    }
                }
            }
            .padding(Layout.quickExpenseGridInset)
        } header: {
            Text(.todayQuickExpense)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, Layout.sectionHeaderHorizontalInset)
                .padding(.vertical, Layout.sectionHeaderVerticalInset)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
    
    // MARK: - Компоненты

    private func quickExpenseButton(category: ExpenseCategory) -> some View {
        Button {
            haptics.trigger(.add)
            onSelect(category, nil)
        } label: {
            HStack(alignment: .center) {
                Image(systemName: category.primaryIcon)
                    .frame(width: Layout.quickExpenseIconSize, height: Layout.quickExpenseIconSize)
                    .foregroundStyle(category.accentColor)
                    .shadow(color: category.accentColor, radius: Layout.quickExpenseShadowRadius)
                Text(category.localizedResource)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, Layout.quickExpenseHorizontalInset)
            .padding(.vertical, Layout.quickExpenseVerticalInset)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.glassProminent)
        .tint(buttonTint)
        .foregroundStyle(Color.primary)
    }
    
    private func quickExpenseButton(subcategory: ExpenseSubcategory) -> some View {
        Button {
            haptics.trigger(.add)
            onSelect(subcategory.category, subcategory)
        } label: {
            Image(systemName: subcategory.primaryIcon)
                .frame(width: Layout.quickExpenseIconSize, height: Layout.quickExpenseIconSize)
                .foregroundStyle(subcategory.accentColor)
                .shadow(color: subcategory.accentColor, radius: Layout.quickExpenseShadowRadius)
                .font(.subheadline.weight(.medium))
                .padding(.vertical, Layout.quickExpenseVerticalInset)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .tint(buttonTint)
        .foregroundStyle(Color.primary)
    }
}
