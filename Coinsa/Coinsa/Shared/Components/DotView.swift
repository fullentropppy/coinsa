//
//  DotView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 15.04.2026.
//

import SwiftUI

struct DotView: View {
    // MARK: - Свойства

    private let fillColor: Color

    // MARK: - Инициализация
    
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

private struct PreviewContent: View {
    let colorScheme: ColorScheme
    
    var body: some View {
        PreviewWrapper(colorScheme: colorScheme) {
            VStack(spacing: 20) {
                DotView(.red)
                DotView(.yellow)
                DotView(.green)
            }
        }
    }
}

#Preview("Light") {
    PreviewContent(colorScheme: .light)
}

#Preview("Dark") {
    PreviewContent(colorScheme: .dark)
}

