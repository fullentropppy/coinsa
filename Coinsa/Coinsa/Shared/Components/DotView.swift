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

private extension DotView {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            DotView(.red)
            DotView(.yellow)
            DotView(.green)
        }
    }
}

#Preview("Light") {
    DotView.makePreview(colorScheme: .light)
}

#Preview("Dark") {
    DotView.makePreview(colorScheme: .dark)
}

