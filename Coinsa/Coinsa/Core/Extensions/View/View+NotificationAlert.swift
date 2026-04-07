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
        message: LocalizedStringResource
    ) -> some View {
        self.alert(title, isPresented: isPresented) {
            Button(.commonOk, role: .cancel) {}
        } message: {
            Text(message)
        }
    }
}
