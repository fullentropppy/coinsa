//
//  View+DeleteConfirmationAlert.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.03.2026.
//

import SwiftUI

extension View {
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
