//
//  View+FormValidationBanner.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.09.2026.
//

import SwiftUI

extension View {
    /// Показывает верхнюю плашку с ошибкой заполнения формы.
    func formValidationBanner(_ notice: Binding<FormValidationNotice?>) -> some View {
        modifier(FormValidationBannerModifier(notice: notice))
    }
}

private struct FormValidationBannerModifier: ViewModifier {
    // MARK: - Константы

    private enum Layout {
        /// Длительность появления и скрытия сообщения об ошибке формы.
        static let animationDuration: TimeInterval = 0.25
        /// Время показа сообщения об ошибке перед автоматическим скрытием в наносекундах.
        static let displayDurationNanoseconds: UInt64 = 1_000_000_000
    }

    // MARK: - Окружение

    @Environment(\.haptics) private var haptics

    // MARK: - Состояние

    @Binding var notice: FormValidationNotice?
    @State private var dismissTask: Task<Void, Never>?

    // MARK: - Тело View

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let notice {
                    FormValidationBanner(message: notice.message)
                        .id(notice.id)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .onTapGesture {
                            self.notice = nil
                        }
                }
            }
            .animation(.snappy(duration: Layout.animationDuration), value: notice?.id)
            .onChange(of: notice?.id) { _, newValue in
                handleNoticeChange(newValue)
            }
            .onDisappear {
                dismissTask?.cancel()
            }
    }

    // MARK: - Действия

    private func handleNoticeChange(_ id: UUID?) {
        dismissTask?.cancel()

        guard id != nil else { return }

        haptics.trigger(.warning)
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: Layout.displayDurationNanoseconds)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.snappy(duration: Layout.animationDuration)) {
                    notice = nil
                }
            }
        }
    }
}
