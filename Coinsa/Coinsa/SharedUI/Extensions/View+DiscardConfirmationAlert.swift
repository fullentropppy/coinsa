//
//  View+DiscardConfirmationAlert.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 24.03.2026.
//

import SwiftUI

extension View {
    func discardConfirmationAlert(
        isPresented: Binding<Bool>,
        onConfirm: @escaping () -> Void
    ) -> some View {
        self.modifier(
            ConfirmationAlertModifier(
                isPresented: isPresented,
                title: .discardTitle,
                message: .discardMessage,
                destuctiveButtonTitle: .discardConfirm,
                onConfirm: onConfirm,
                hapticTypeOnConfirm: .success,
                hapticTypeOnAppear: .warning
            )
        )
    }
}
