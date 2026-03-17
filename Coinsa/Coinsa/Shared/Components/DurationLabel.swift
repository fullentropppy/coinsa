//
//  DurationLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct DurationLabel: View {
    // MARK: - Stored Properties
    
    let days: Int
    let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(days: Int, style: ComponentStyle = .default) {
        self.days = days
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "clock")
            Text(String(days))
        }
        .font(styleFont)
        .foregroundStyle(styleColor)
    }
    
    // MARK: - Components
    
    private var styleFont: Font {
        switch style {
        case .primary:
            return .headline
        case .default, .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    var styleColor: Color {
        switch style {
        case .primary:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension DurationLabel {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            DurationLabel(days: 7, style: .default)
            DurationLabel(days: 14, style: .primary)
            DurationLabel(days: 30, style: .secondary)
            DurationLabel(days: 60, style: .tertiary)
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    DurationLabel.preview(colorScheme: .light)
}

#Preview("Dark") {
    DurationLabel.preview(colorScheme: .dark)
}
