//
//  HapticClient.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import SwiftUI

struct HapticClient {
    var trigger: (HapticType) -> Void
}

extension HapticClient {
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
