//
//  HapticClient.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import UIKit

/// Клиент для генерации тактильных откликов разных типов.
struct HapticClient {
    // MARK: - Свойства

    var trigger: (HapticType) -> Void
}

extension HapticClient {
    // MARK: - Методы

    /// Возвращает клиент, проверяющий разрешение перед каждым тактильным откликом.
    func enabled(when isEnabled: @escaping () -> Bool) -> HapticClient {
        HapticClient { type in
            guard isEnabled() else { return }
            trigger(type)
        }
    }

    // MARK: - Константы

    static let live = HapticClient { type in
        switch type {
        case .add: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .tap: UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .success: UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning: UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error: UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
