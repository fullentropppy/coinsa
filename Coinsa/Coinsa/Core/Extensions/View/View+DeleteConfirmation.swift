//
//  View+DeleteConfirmation.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.03.2026.
//

import SwiftUI

extension View {
    func deleteConfirmationAlert(
        isPresented: Binding<Bool>,
        message: LocalizedStringResource,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.alert(.deleteTitle, isPresented: isPresented) {
            Button(.deleteConfirm, role: .destructive) {
                onConfirm()
            }
            Button(.commonCancel, role: .cancel) {
                onCancel()
            }
        } message: {
            Text(message)
        }
    }
}
