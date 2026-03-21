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
        message: LocalizedStringKey,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.alert("delete.title", isPresented: isPresented) {
            Button("delete.confirm", role: .destructive) {
                onConfirm()
            }
            Button("common.cancel", role: .cancel) {
                onCancel()
            }
        } message: {
            Text(message)
        }
    }
}
