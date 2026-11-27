//
//  View+DiscardConfirmationAlert.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

extension View {
    // MARK: - Методы

    /// Добавляет алерт подтверждения отмены изменений с предустановленными текстами и тактильными откликами.
    /// - Parameters:
    ///   - isPresented: Флаг отображения алерта.
    ///   - onConfirm: Действие при подтверждении отмены изменений.
    /// - Returns: Модифицированное представление.
    func discardConfirmationAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ConfirmationAlertModifier(
                isPresented: isPresented,
                title: .discardTitle,
                message: .discardMessage,
                confirmButtonTitle: .discardConfirm,
                onConfirm: onConfirm,
                confirmButtonRole: .destructive,
                hapticTypeOnConfirm: .success,
                hapticTypeOnAppear: .warning
            )
        )
    }
}
