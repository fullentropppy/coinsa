//
//  View+BlockingOverlay.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 27.11.2026.
//

import SwiftUI

extension View {
    // MARK: - Методы

    /// Передает окно ожидания корневому слою, перекрывающему навигацию и вкладки.
    /// - Parameters:
    ///   - isPresented: Показывать окно и блокировать взаимодействие с приложением.
    ///   - overlay: Содержимое окна с оформлением вызывающего экрана.
    /// - Returns: Представление, передающее окно ближайшему корневому слою.
    func blockingOverlay<Overlay: View>(
        isPresented: Bool,
        @ViewBuilder overlay: () -> Overlay
    ) -> some View {
        preference(
            key: BlockingOverlayPreferenceKey.self,
            value: isPresented ? AnyView(overlay()) : nil
        )
    }

    /// Размещает окна ожидания дочерних экранов над всем содержимым, включая системные панели.
    /// - Returns: Представление с затемняющим слоем, перехватывающим касания до завершения ожидания.
    func blockingOverlayHost() -> some View {
        modifier(BlockingOverlayHostModifier())
    }
}

// MARK: - Передача окна ожидания

private nonisolated struct BlockingOverlayPreferenceKey: PreferenceKey {
    static var defaultValue: AnyView? { nil }

    static func reduce(value: inout AnyView?, nextValue: () -> AnyView?) {
        value = nextValue() ?? value
    }
}

// MARK: - Корневой слой

private struct BlockingOverlayHostModifier: ViewModifier {
    private enum Layout {
        /// Затемнение содержимого под окном ожидания.
        static let dimmingOpacity: Double = 0.2
        /// Длительность появления и исчезновения блокирующего окна в секундах.
        static let animationDuration: TimeInterval = 0.2
        /// Начальный и конечный масштаб окна при появлении и исчезновении.
        static let transitionScale: CGFloat = 0.96
    }

    func body(content: Content) -> some View {
        content.overlayPreferenceValue(BlockingOverlayPreferenceKey.self) { overlay in
            ZStack {
                if let overlay {
                    Color.black.opacity(Layout.dimmingOpacity)
                        .ignoresSafeArea()
                        .onTapGesture {}
                        .transition(.opacity)

                    overlay
                        .transition(.scale(scale: Layout.transitionScale).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(overlay != nil)
            .animation(.easeInOut(duration: Layout.animationDuration), value: overlay != nil)
        }
    }
}

// MARK: - Превью

#Preview{
    NavigationStack {
        List {
            Text(.tripRatesRefreshAction)
        }
        .blockingOverlay(isPresented: true) {
            BlockingProgressView(title: .tripRatesRefreshProgress, width: 160, height: 160)
        }
    }
    .blockingOverlayHost()
}
