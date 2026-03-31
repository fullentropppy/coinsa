//
//  PrimaryButtonView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 31.03.2026.
//

import SwiftUI

struct PrimaryAddButtonView: View {
    // MARK: - Stored Properties
    
    let action: () -> Void
    let isOnLeft: Bool
    
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
    
    // MARK: - Components
    
    
}

// MARK: - Previews

#Preview("Light") {
    PrimaryAddButtonView(action: {}, isOnLeft: true).preferredColorScheme(.light)
}

#Preview("Dark") {
    PrimaryAddButtonView(action: {}, isOnLeft: false).preferredColorScheme(.dark)
}
