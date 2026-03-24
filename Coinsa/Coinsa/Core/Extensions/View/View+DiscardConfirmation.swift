//
//  View+DiscardConfirmation.swift
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
        self.alert("discard.title", isPresented: isPresented) {
            Button("discard.confirm", role: .destructive) {
                onConfirm()
            }
            Button("discard.keepEditing", role: .cancel) { }
        } message: {
            Text("discard.message")
        }
    }
}
