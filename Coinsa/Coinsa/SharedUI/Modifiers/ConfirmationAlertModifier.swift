//
//  ConfirmationAlertModifier.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.04.2026.
//

import SwiftUI

/// Модификатор для отображения алерта подтверждения с поддержкой тактильных откликов.
struct ConfirmationAlertModifier: ViewModifier {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    let isPresented: Binding<Bool>
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let destuctiveButtonTitle: LocalizedStringResource
    let onConfirm: () -> Void
    let hapticTypeOnConfirm: HapticType?
    let onCancel: (() -> Void)?
    let hapticTypeOnCancel: HapticType?
    let hapticTypeOnAppear: HapticType?
    
    // MARK: - Инициализация
    
    /// Создаёт модификатор алерта подтверждения.
    /// - Parameters:
    ///   - isPresented: Флаг отображения алерта.
    ///   - title: Заголовок.
    ///   - message: Сообщение.
    ///   - destuctiveButtonTitle: Текст деструктивной кнопки.
    ///   - onConfirm: Действие при подтверждении.
    ///   - hapticTypeOnConfirm: Тактильный отклик при подтверждении.
    ///   - onCancel: Действие при отмене.
    ///   - hapticTypeOnCancel: Тактильный отклик при отмене.
    ///   - hapticTypeOnAppear: Тактильный отклик при появлении алерта.
    init(
        isPresented: Binding<Bool>,
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        destuctiveButtonTitle: LocalizedStringResource,
        onConfirm: @escaping () -> Void,
        hapticTypeOnConfirm: HapticType? = nil,
        onCancel: (() -> Void)? = nil,
        hapticTypeOnCancel: HapticType? = nil,
        hapticTypeOnAppear: HapticType? = nil
    ) {
        self.isPresented = isPresented
        self.title = title
        self.message = message
        self.destuctiveButtonTitle = destuctiveButtonTitle
        self.onConfirm = onConfirm
        self.hapticTypeOnConfirm = hapticTypeOnConfirm
        self.onCancel = onCancel
        self.hapticTypeOnCancel = hapticTypeOnCancel
        self.hapticTypeOnAppear = hapticTypeOnAppear
    }
    
    // MARK: - Тело View
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented) {
                Button(destuctiveButtonTitle, role: .destructive) {
                    if let hapticTypeOnConfirm {
                        haptics.trigger(hapticTypeOnConfirm)
                    }
                    onConfirm()
                }
                Button(.cancel, role: .cancel) {
                    if let hapticTypeOnCancel {
                        haptics.trigger(hapticTypeOnCancel)
                    }
                    if let onCancel {
                        onCancel()
                    }
                }
            } message: {
                Text(message)
            }
            .onChange(of: isPresented.wrappedValue) { _, newValue in
                if newValue, let hapticTypeOnAppear {
                    haptics.trigger(hapticTypeOnAppear)
                }
            }
    }
}
