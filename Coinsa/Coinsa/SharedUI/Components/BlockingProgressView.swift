//
//  BlockingProgressView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.11.2026.
//

import SwiftUI

/// Окно ожидания для отображения поверх интерфейса через блокирующий слой.
struct BlockingProgressView: View {
    // MARK: - Свойства

    private let title: LocalizedStringResource
    private let width: CGFloat
    private let height: CGFloat

    // MARK: - Константы оформления

    private enum Layout {
        /// Радиус скругления стеклянного окна ожидания в пунктах.
        static let cornerRadius: CGFloat = 40
    }

    // MARK: - Инициализация

    /// Создает стеклянное окно с системным индикатором ожидания и заданными размерами.
    /// - Parameters:
    ///   - title: Локализованный заголовок под индикатором ожидания.
    ///   - width: Ширина окна в пунктах.
    ///   - height: Высота окна в пунктах.
    init(title: LocalizedStringResource, width: CGFloat, height: CGFloat) {
        self.title = title
        self.width = width
        self.height = height
    }

    // MARK: - Тело View

    var body: some View {
        ProgressView(title)
            .controlSize(.large)
            .multilineTextAlignment(.center)
            .padding()
            .frame(width: width, height: height)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
    }
}

// MARK: - Превью

#Preview("Square") {
    BlockingProgressView(title: .tripRatesRefreshProgress, width: 160, height: 160)
}

#Preview("Wide") {
    BlockingProgressView(title: .tripRatesRefreshProgress, width: 240, height: 160)
}
