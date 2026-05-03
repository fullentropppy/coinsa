//
//  View+LoadingState.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 09.04.2026.
//

import SwiftUI

extension View {
    /// Применяет визуальное состояние загрузки к представлению.
    /// - Parameter isLoading: Флаг загрузки.
    /// - Returns: Модифицированное представление.
    func loadingState(_ isLoading: Bool) -> some View {
        self
            .opacity(isLoading ? 0.46 : 1)
            .disabled(isLoading)
    }
}
