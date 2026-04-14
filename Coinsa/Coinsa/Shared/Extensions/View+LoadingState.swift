//
//  View+LoadingState.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import SwiftUI

extension View {
    func loadingState(_ isLoading: Bool) -> some View {
        self
            .opacity(isLoading ? 0.5 : 1)
            .disabled(isLoading)
    }
}
