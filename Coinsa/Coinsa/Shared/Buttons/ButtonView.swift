//
//  ToolbarButtonView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct ButtonView: View {
    // MARK: - Stored Properties
    
    private let symbolName: String
    private let action: () -> Void
    
    // MARK: - Initialization
    
    private init(symbolName: String, action: @escaping () -> Void) {
        self.symbolName = symbolName
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
        }
    }
}

// MARK: - Convenience Initializers

extension ButtonView {
    static func add(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbolName: "plus", action: action)
    }
    
    static func edit(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbolName: "pencil", action: action)
    }
    
    static func save(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbolName: "checkmark", action: action)
    }
    
    static func delete(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbolName: "trash", action: action)
    }
    
    static func close(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbolName: "xmark", action: action)
    }
        
    static func settings(action: @escaping () -> Void) -> ButtonView {
        ButtonView(symbolName: "gear", action: action)
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
