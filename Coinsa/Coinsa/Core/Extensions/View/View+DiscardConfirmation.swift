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
        self.alert(.discardTitle, isPresented: isPresented) {
            Button(.discardConfirm, role: .destructive) {
                onConfirm()
            }
            Button(.discardKeepEditing, role: .cancel) {}
        } message: {
            Text(.discardMessage)
        }
    }
}
