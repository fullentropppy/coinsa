//
//  ToolbarButtonView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct ButtonView: View {
    // MARK: - Stored Properties
    
    private let icon: String
    private let action: () -> Void
    
    // MARK: - Initialization
    
    private init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
        }
    }
}

// MARK: - Convenience Initializers

extension ButtonView {
    static func add(action: @escaping () -> Void) -> ButtonView {
        ButtonView(icon: "plus", action: action)
    }
    
    static func edit(action: @escaping () -> Void) -> ButtonView {
        ButtonView(icon: "pencil", action: action)
    }
    
    static func save(action: @escaping () -> Void) -> ButtonView {
        ButtonView(icon: "checkmark", action: action)
    }
    
    static func delete(action: @escaping () -> Void) -> ButtonView {
        ButtonView(icon: "trash", action: action)
    }
    
    static func close(action: @escaping () -> Void) -> ButtonView {
        ButtonView(icon: "xmark", action: action)
    }
        
    static func settings(action: @escaping () -> Void) -> ButtonView {
        ButtonView(icon: "gear", action: action)
    }
}

// MARK: - Previews

private var previewButtons: some View {
    HStack {
        ButtonView.add(action: {})
        ButtonView.edit(action: {})
        ButtonView.save(action: {})
        ButtonView.delete(action: {})
        ButtonView.close(action: {})
        ButtonView.settings(action: {})
    }
}

#Preview("Light") {
    previewButtons.preferredColorScheme(.light)
}

#Preview("dark") {
    previewButtons.preferredColorScheme(.dark)
}
