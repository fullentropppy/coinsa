//
//  View+DeleteConfirmationAlert.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.03.2026.
//

import SwiftUI

extension View {
    /// Добавляет алерт подтверждения удаления с предустановленным стилем и тактильными откликами.
    /// - Parameters:
    ///   - isPresented: Флаг отображения алерта.
    ///   - title: Заголовок.
    ///   - message: Сообщение.
    ///   - onConfirm: Действие при подтверждении удаления.
    ///   - onCancel: Действие при отмене удаления.
    /// - Returns: Модифицированное представление.
    func deleteConfirmationAlert(
        isPresented: Binding<Bool>,
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ConfirmationAlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                destuctiveButtonTitle: .delete,
                onConfirm: onConfirm,
                hapticTypeOnConfirm: .success,
                onCancel: onCancel,
                hapticTypeOnAppear: .warning
            )
        )
    }
}
