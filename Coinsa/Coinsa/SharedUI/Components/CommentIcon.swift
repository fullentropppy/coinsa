//
//  CommentIcon.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 22.11.2026.
//

import SwiftUI

/// Индикатор комментария в строке траты или рядом с многострочным текстом.
struct CommentIcon: View {
    // MARK: - Свойства

    var isCompact = false

    // MARK: - Тело View

    var body: some View {
        if isCompact {
            AppIcon(AppSymbols.ellipsisBubble, style: .metadata)
        } else {
            AppIcon(AppSymbols.ellipsisBubble, style: .formLabel)
                .padding(.vertical, ViewLayout.Comment.iconVerticalInset)
        }
    }
}

// MARK: - Превью

#Preview {
    HStack(spacing: 20) {
        CommentIcon()
        CommentIcon(isCompact: true)
    }
    .padding()
}
