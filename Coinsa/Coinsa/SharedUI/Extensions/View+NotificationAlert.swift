//
//  View+NotificationAlert.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import SwiftUI

extension View {
    func notificationAlert(
        isPresented: Binding<Bool>,
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        isError: Bool = false,
        onAppear: (() -> Void)? = nil
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
