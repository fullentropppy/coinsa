//
//  ThirdPartyLink.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 11.04.2026.
//

import SwiftUI

struct ThirdPartyLink: View {
    // MARK: - Stored Properties
    
    let name: LocalizedStringResource
    let description: LocalizedStringResource
    let url: URL
    
    // MARK: - Body
    
    var body: some View {
        Link(destination: url) {
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .tint(.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.link)
            }
        }
    }
}

// MARK: - Previews

private extension ThirdPartyLink {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        return List {
            ThirdPartyLink(
                name: .thirdPartyHexarate,
                description: .thirdPartyHexarateDescription,
                url: URL(string: "example.com")!
            )
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    ThirdPartyLink.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    ThirdPartyLink.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
