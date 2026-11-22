//
//  KeyboardClearAction.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 12.11.2026.
//

import SwiftUI

/// Состояние и действие очистки активного поля ввода.
struct KeyboardClearAction {
    // MARK: - Свойства

    let isEmpty: Bool
    let clear: () -> Void
}

extension FocusedValues {
    // MARK: - Свойства

    var keyboardClearAction: KeyboardClearAction? {
        get { self[KeyboardClearActionKey.self] }
        set { self[KeyboardClearActionKey.self] = newValue }
    }
}

private struct KeyboardClearActionKey: FocusedValueKey {
    // MARK: - Вложенные типы

    typealias Value = KeyboardClearAction
}
