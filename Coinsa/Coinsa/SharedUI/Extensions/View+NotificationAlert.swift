//
//  View+NotificationAlert.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import SwiftUI

extension View {
    /// Добавляет информационный алерт (только с кнопкой "OK") с тактильным откликом в зависимости от типа уведомления.
    /// - Parameters:
    ///   - isPresented: Флаг отображения алерта.
    ///   - title: Заголовок.
    ///   - message: Сообщение.
    ///   - isError: Флаг ошибки. При `true` используется тактильный отклик `.error`, иначе - `.success`.
    /// - Returns: Модифицированное представление.
    func notificationAlert(
        isPresented: Binding<Bool>,
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        isError: Bool = false
    ) -> some View {
        self.modifier(
            NotificationAlertModifier(
                isPresented: isPresented,
                title: title,
                message: message,
                hapticTypeOnChange: isError ? .error : .success
            )
        )
    }
}
