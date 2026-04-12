//
//  PaymentMethodLabel.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.04.2026.
//

import SwiftUI

struct PaymentMethodLabel: View {
    // MARK: - Stored Properties

    var method: PaymentMethod

    // MARK: - Body
    
    var body: some View {
        HStack {
            Image(systemName: method.labelIcon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(method.localizedResource)
        }
    }
}

// MARK: - Previews

private extension PaymentMethodLabel {
    static func makePreview(locale: Locale, colorScheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(PaymentMethod.allCases, id: \.id) { (method: PaymentMethod) in
                PaymentMethodLabel(method: method)
            }
        }
        .environment(\.locale, locale)
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light - RU") {
    PaymentMethodLabel.makePreview(locale: PreviewLocale.ru, colorScheme: .light)
}

#Preview("Dark - EN") {
    PaymentMethodLabel.makePreview(locale: PreviewLocale.en, colorScheme: .dark)
}
