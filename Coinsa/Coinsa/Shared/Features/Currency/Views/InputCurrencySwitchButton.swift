//
//  InputCurrencySwitchButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import SwiftUI

struct InputCurrencySwitchButton: View {
    // MARK: - Stored Properties
    
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left.arrow.right")
                .fontWeight(.semibold)
                .imageScale(.small)
        }
        .frame(width: 16)
        .buttonStyle(.borderless)
        .foregroundStyle(.accent)
    }
}
