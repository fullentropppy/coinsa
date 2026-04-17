//
//  NotificationAlertModifier.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 18.04.2026.
//

import SwiftUI

struct NotificationAlertModifier: ViewModifier {
    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics
    
    // MARK: - Свойства
    
    let isPresented: Binding<Bool>
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    let hapticTypeOnAppear: HapticType?
    
    // MARK: - Инициализация
    
    init(
        isPresented: Binding<Bool>,
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        hapticTypeOnChange: HapticType? = nil
    ) {
        self.isPresented = isPresented
        self.title = title
        self.message = message
        self.hapticTypeOnAppear = hapticTypeOnChange
    }
    
    // MARK: - Тело View
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented) {
                Button(.ok, role: .cancel) {}
            } message: {
                Text(message)
            }
            .onChange(of: isPresented.wrappedValue) { _, newValue in
                if newValue, let hapticType = hapticTypeOnAppear {
                    haptics.trigger(hapticType)
                }
            }
    }
}
