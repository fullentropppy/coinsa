//
//  DetailActionsMenu.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import SwiftUI

/// Меню действий детального экрана с редактированием, удалением и дополнительными пунктами.
struct DetailActionsMenu<AdditionalActions: View>: View {
    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let onEdit: () -> Void
    private let onDelete: () -> Void
    private let additionalActions: AdditionalActions

    // MARK: - Инициализация

    /// Создает меню с общими кнопками редактирования и удаления и дополнительными действиями экрана.
    /// - Parameters:
    ///   - title: Локализованный заголовок кнопки меню.
    ///   - onEdit: Действие открытия редактора.
    ///   - onDelete: Действие запроса подтверждения удаления объекта.
    ///   - additionalActions: Пункты после редактирования; по умолчанию отсутствуют.
    init(
        title: LocalizedStringResource,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        @ViewBuilder additionalActions: () -> AdditionalActions = { EmptyView() }
    ) {
        self.title = title
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.additionalActions = additionalActions()
    }

    // MARK: - Тело View

    var body: some View {
        Menu {
            ToolbarButton.edit(showsTitle: true, action: onEdit)
            additionalActions
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label(.delete, systemImage: AppSymbols.trash)
            }
        } label: {
            Label(title, systemImage: AppSymbols.ellipsis)
        }
    }
}

// MARK: - Превью

#Preview {
    NavigationStack {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DetailActionsMenu(title: .tripActions, onEdit: {}, onDelete: {})
                }
            }
    }
}
