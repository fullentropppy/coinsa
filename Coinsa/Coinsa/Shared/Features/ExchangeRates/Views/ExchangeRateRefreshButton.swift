//
//  ExchangeRateRefreshButton.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 07.04.2026.
//

import SwiftUI

struct ExchangeRateRefreshButton: View {
    // MARK: - Stored Properties
    
    let isLoading: Bool
    let onRefresh: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onRefresh) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .fontWeight(.semibold)
                        .imageScale(.small)
                }
            }
            .frame(width: 16)
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.tertiary)
        .disabled(isLoading)
    }
}
