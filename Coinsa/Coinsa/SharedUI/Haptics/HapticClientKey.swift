//
//  HapticClientKey.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 17.04.2026.
//

import SwiftUI

/// Ключ окружения для доступа к клиенту тактильных откликов.
private struct HapticClientKey: EnvironmentKey {
    static let defaultValue = HapticClient.live
}

extension EnvironmentValues {
    var haptics: HapticClient {
        get { self[HapticClientKey.self] }
        set { self[HapticClientKey.self] = newValue }
    }
}
