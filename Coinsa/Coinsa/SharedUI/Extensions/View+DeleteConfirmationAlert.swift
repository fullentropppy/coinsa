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
        self.alert(title, isPresented: isPresented) {
            Button(.delete, role: .destructive) {
                onConfirm()
            }
            Button(.cancel, role: .cancel) {
                onCancel()
            }
        } message: {
            Text(message)
        }
    }
}
