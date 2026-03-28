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
            .padding(20)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.accent)
            .glassEffect(.regular.interactive(), in: .circle)
            .contentShape(Circle())
    }
}
