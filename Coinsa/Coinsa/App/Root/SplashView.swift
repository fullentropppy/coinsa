//
//  SplashView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.04.2026.
//

import SwiftUI

/// Экран-заставка при запуске приложения.
struct SplashView: View {
    // MARK: - Константы

    private enum Layout {
        /// Начальный масштаб иконки перед появлением.
        static let initialIconScale: Double = 0.8
        /// Размер иконки на экране запуска.
        static let iconSize: CGFloat = 80
        /// Длительность отклика пружины при появлении иконки.
        static let appearanceResponse: TimeInterval = 0.42
        /// Коэффициент затухания пружины появления.
        static let appearanceDamping: Double = 0.68
        /// Длительность отклика пружины при скрытии заставки.
        static let disappearanceResponse: TimeInterval = 0.46
        /// Коэффициент затухания пружины скрытия.
        static let disappearanceDamping: Double = 0.82
        /// Интервал между появлением, тактильными откликами и началом скрытия в миллисекундах.
        static let hapticIntervalMilliseconds: Int = 200
        /// Задержка завершения заставки после начала скрытия в миллисекундах.
        static let completionDelayMilliseconds: Int = 2000
    }

    // MARK: - Окружение
    
    @Environment(\.haptics) private var haptics

    // MARK: - Свойства

    @State private var backgroundOpacity = 1.0
    @State private var iconScale = Layout.initialIconScale
    @State private var iconOpacity = 0.0
    @State private var hasStartedAnimation = false

    // MARK: - Зависимости
    
    let onFinished: () -> Void
    
    // MARK: - Тело View

    var body: some View {
        Color.accent
            .overlay {
                Image(systemName: AppSymbols.lizardFill)
                    .font(.system(size: Layout.iconSize, weight: .bold))
                    .foregroundStyle(.windowBackground)
                    .opacity(iconOpacity)
                    .scaleEffect(iconScale)
            }
            .opacity(backgroundOpacity)
            .ignoresSafeArea()
            .task {
                await runAnimationIfNeeded()
            }
    }

    // MARK: - Приватные методы

    @MainActor
    private func runAnimationIfNeeded() async {
        guard !hasStartedAnimation, !Task.isCancelled else { return }
        hasStartedAnimation = true
        backgroundOpacity = 1
        iconScale = Layout.initialIconScale
        iconOpacity = 0
        
        withAnimation(.spring(response: Layout.appearanceResponse, dampingFraction: Layout.appearanceDamping)) {
            iconOpacity = 1
            iconScale = 1
        }
        
        do {
            try await Task.sleep(for: .milliseconds(Layout.hapticIntervalMilliseconds))
            try Task.checkCancellation()
            haptics.trigger(.add)

            try await Task.sleep(for: .milliseconds(Layout.hapticIntervalMilliseconds))
            try Task.checkCancellation()
            haptics.trigger(.tap)

            withAnimation(.spring(response: Layout.disappearanceResponse, dampingFraction: Layout.disappearanceDamping)) {
                iconOpacity = 0
                iconScale = 0
                backgroundOpacity = 0
            }

            try await Task.sleep(for: .milliseconds(Layout.completionDelayMilliseconds))
            try Task.checkCancellation()
            onFinished()
        } catch {
            hasStartedAnimation = false
        }
    }
}

// MARK: - Превью

#Preview {
    TimelineView(.periodic(from: .now, by: 2.0)) { timeline in
        SplashView(onFinished: {})
            .id(timeline.date.timeIntervalSince1970)
    }
}
