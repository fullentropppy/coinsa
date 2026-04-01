//
//  PrimaryAddButtonView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 31.03.2026.
//

import SwiftUI

struct PrimaryAddButtonView: View {
    // MARK: - Stored Properties
    
    let isOnLeft: Bool
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            if !isOnLeft {
                Spacer()
            }
            
            Button {
                action()
            } label: {
                Image(systemName: "text.badge.plus")
                    .font(.title.weight(.semibold))
            }
            .padding(16)
            .contentShape(Circle())
            .glassEffect(.regular.interactive(), in: .circle)
            
            if isOnLeft {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Previews

private extension PrimaryAddButtonView {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        HStack {
            PrimaryAddButtonView(isOnLeft: true) {}
            PrimaryAddButtonView(isOnLeft: false) {}
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    PrimaryAddButtonView.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    PrimaryAddButtonView.makePreview(colorScheme: .dark)
}
