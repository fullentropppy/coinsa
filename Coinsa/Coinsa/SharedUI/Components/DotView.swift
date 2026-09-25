//
//  DotView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

/// Круглая точка-индикатор.
struct DotView: View {
    // MARK: - Свойства

    private let fillColor: Color

    // MARK: - Инициализация
    
    /// Создает точку-индикатор с указанным цветом.
    /// - Parameter fillColor: Цвет заливки точки.
    init(_ fillColor: Color) {
        self.fillColor = fillColor
    }
    
    // MARK: - Тело View
    
    var body: some View {
        Image(systemName: "circle.fill")
            .imageScale(.small)
            .foregroundStyle(fillColor.gradient)
    }
}

// MARK: - Превью

#Preview {
    VStack(spacing: 20) {
        DotView(.red)
        DotView(.yellow)
        DotView(.green)
    }
}
