//
//  EventToolbarTitleView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 21.03.2026.
//

import SwiftUI

struct ContextToolbarTitleView: View {
    // MARK: - Stored Properties
    
    let title: String
    let subtitle: String?

    private var minXPadding: Double {
        subtitle == nil ? 20 : 0
    }
    
    private var minYPadding: Double {
        subtitle == nil ? 8 : 0
    }
    
    // MARK: - Initialization
    
    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            Text(title).font(.headline)
            
            if let subtitle {
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .padding(.minimum(minXPadding, minYPadding))
        .padding(.vertical, 6)
        .padding(.horizontal, 20)
        .glassEffect(.regular, in: Capsule())
    }
}

// MARK: - Previews

private extension ContextToolbarTitleView {
    static func preview(locale: Locale, colorScheme: ColorScheme) -> some View {
        NavigationStack {
            Form {
                EmptyView()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ContextToolbarTitleView(
                        title: PreviewLocation.tokyo.rawValue,
                        subtitle: PreviewTrip.japan.rawValue
                    )
                }
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ContextToolbarTitleView.preview(locale: PreviewLocale.ru.locale, colorScheme: .light)
}

#Preview("Dark - EN") {
    ContextToolbarTitleView.preview(locale: PreviewLocale.en.locale, colorScheme: .dark)
}

