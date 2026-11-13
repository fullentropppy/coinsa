//
//  DetailActionsMenu.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 13.11.2026.
//

import SwiftUI

/// Меню действий детального экрана с редактированием и дополнительными пунктами.
struct DetailActionsMenu<AdditionalActions: View>: View {
    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let onEdit: () -> Void
    private let additionalActions: AdditionalActions

    // MARK: - Инициализация

    /// Создает меню с общей кнопкой редактирования и дополнительными действиями экрана.
    /// - Parameters:
    ///   - title: Локализованный заголовок кнопки меню.
    ///   - onEdit: Действие открытия редактора.
    ///   - additionalActions: Пункты после редактирования; по умолчанию отсутствуют.
    init(
        title: LocalizedStringResource,
        onEdit: @escaping () -> Void,
        @ViewBuilder additionalActions: () -> AdditionalActions = { EmptyView() }
    ) {
        self.title = title
        self.onEdit = onEdit
        self.additionalActions = additionalActions()
    }

    // MARK: - Тело View

    var body: some View {
        Menu {
            ToolbarButton.edit(showsTitle: true, action: onEdit)
            additionalActions
        } label: {
            Label(title, systemImage: "ellipsis")
        }
    }
}

// MARK: - Превью

#Preview {
    NavigationStack {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DetailActionsMenu(title: .tripActions, onEdit: {})
                }
            }
    }
}
