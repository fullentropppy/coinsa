//
//  PrimaryButtonStyle.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .padding(15)
            .background(Circle().fill(Color.accentColor))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding(20)
    }
}
