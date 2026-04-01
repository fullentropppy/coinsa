//
//  TripLocationCountLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

import SwiftUI

struct TripLocationCountLabel: View {
    // MARK: - Stored Properties
    
    private let count: Int
    private let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(count: Int, style: ComponentStyle = .default) {
        self.count = count
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "mappin.and.ellipse")
            Text(String(count))
        }
        .font(styleFont)
        .foregroundStyle(styleColor)
    }
    
    // MARK: - Components
    
    private var styleFont: Font {
        switch style {
        case .title:
            return .headline
        case .default, .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    private var styleColor: Color {
        switch style {
        case .title:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension TripLocationCountLabel {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            TripLocationCountLabel(count: 4)
            TripLocationCountLabel(count: 4, style: .title)
            TripLocationCountLabel(count: 4, style: .secondary)
            TripLocationCountLabel(count: 4, style: .tertiary)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    TripLocationCountLabel.preview(colorScheme: .light)
}

#Preview("Dark") {
    TripLocationCountLabel.preview(colorScheme: .dark)
}
