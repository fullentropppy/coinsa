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
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.alert(title, isPresented: isPresented) {
            Button(.commonDelete, role: .destructive) {
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
