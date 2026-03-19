//
//  ToolbarButtonView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct ButtonView: View {
    // MARK: - Stored Properties
    
    private let symbol: String
    private let action: () -> Void
    
    // MARK: - Initialization
    
    private init(symbol: String, action: @escaping () -> Void) {
        self.symbol = symbol
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
        }
    }
}

// MARK: - Convenience Initializers

extension ButtonView {
    static func add(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbol: "plus", action: action)
    }
    
    static func edit(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbol: "pencil", action: action)
    }
    
    static func save(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbol: "checkmark", action: action)
    }
    
    static func delete(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbol: "trash", action: action)
    }
    
    static func close(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbol: "xmark", action: action)
    }
        
    static func settings(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbol: "gear", action: action)
    }
}

// MARK: - Previews

private extension ButtonView {
    static func preview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            ButtonView.add(action: {})
            ButtonView.edit(action: {})
            ButtonView.save(action: {})
            ButtonView.delete(action: {})
            ButtonView.close(action: {})
            ButtonView.settings(action: {})
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    ButtonView.preview(colorScheme: .light)
}

#Preview("dark") {
    ButtonView.preview(colorScheme: .dark)
}
