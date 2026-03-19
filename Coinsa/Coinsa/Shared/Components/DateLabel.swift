//
//  DateLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 19.03.2026.
//

import SwiftUI

struct DateLabel: View {
    // MARK: - Stored Properties
    
    private let date1: Date
    private let date2: Date?
    private let showsSymbol: Bool
    private let style: ComponentStyle
    
    // MARK: - Initialization
    
    init(
        _ date: Date,
        showsSymbol: Bool = false,
        style: ComponentStyle = .default
    ) {
        self.date1 = date
        self.date2 = nil
        self.showsSymbol = showsSymbol
        self.style = style
    }
    
    init(
        from date1: Date,
        to date2: Date,
        showsSymbol: Bool = false,
        style: ComponentStyle = .default
    ) {
        self.date1 = date1
        self.date2 = date2
        self.showsSymbol = showsSymbol
        self.style = style
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            if showsSymbol {
                Image(systemName: "calendar").foregroundStyle(.secondary)
            }
            
            Group {
                if let endDate = date2 {
                    Text(date1..<endDate, format: Date.intervalFormat)
                } else {
                    Text(date1, format: Date.displayFormatWithTime)
                }
            }
            .foregroundStyle(styleColor)
        }
        .font(styleFont)
    }
    
    // MARK: - Components
    
    private var styleFont: Font {
        switch style {
        case .default:
            return .body
        case .primary:
            return .headline
        case .secondary:
            return .subheadline
        case .tertiary:
            return .footnote
        }
    }
    
    var styleColor: Color {
        switch style {
        case .default, .primary:
            return .primary
        default:
            return .secondary
        }
    }
}

// MARK: - Previews

private extension DateLabel {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        let now = Date.now
        let weekAhead = now.addingTimeInterval(604800)
        
        return VStack(spacing: 40) {
            VStack(spacing: 20) {
                DateLabel(now)
                DateLabel(now, style: .primary)
                DateLabel(now, style: .secondary)
                DateLabel(now, style: .tertiary)
            }
            
            VStack(spacing: 20) {
                DateLabel(now, showsSymbol: true)
                DateLabel(now, showsSymbol: true, style: .primary)
                DateLabel(now, showsSymbol: true, style: .secondary)
                DateLabel(now, showsSymbol: true, style: .tertiary)
            }
            
            VStack(spacing: 20) {
                DateLabel(from: now, to: weekAhead)
                DateLabel(from: now, to: weekAhead, style: .primary)
                DateLabel(from: now, to: weekAhead, style: .secondary)
                DateLabel(from: now, to: weekAhead, style: .tertiary)
            }
            
            VStack(spacing: 20) {
                DateLabel(from: now, to: weekAhead, showsSymbol: true)
                DateLabel(from: now, to: weekAhead, showsSymbol: true, style: .primary)
                DateLabel(from: now, to: weekAhead, showsSymbol: true, style: .secondary)
                DateLabel(from: now, to: weekAhead, showsSymbol: true, style: .tertiary)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    DateLabel.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    DateLabel.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}
