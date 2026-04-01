//
//  ToolbarButtonView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 08.03.2026.
//

import SwiftUI

struct ToolbarButtonView: View {
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
        Button {
            action()
        } label: {
            Image(systemName: icon)
        }
    }
}

// MARK: - Convenience Initializers

extension ToolbarButtonView {
    static func add(action: @escaping () -> Void) -> ToolbarButtonView {
        ToolbarButtonView(icon: "plus", action: action)
    }
    
    static func edit(action: @escaping () -> Void) -> ToolbarButtonView {
        ToolbarButtonView(icon: "pencil", action: action)
    }
    
    static func save(action: @escaping () -> Void) -> ToolbarButtonView {
        ToolbarButtonView(icon: "checkmark", action: action)
    }
    
    static func delete(action: @escaping () -> Void) -> ToolbarButtonView {
        ToolbarButtonView(icon: "trash", action: action)
    }
    
    static func close(action: @escaping () -> Void) -> ToolbarButtonView {
        ToolbarButtonView(icon: "xmark", action: action)
    }
        
    static func settings(action: @escaping () -> Void) -> ToolbarButtonView {
        ToolbarButtonView(icon: "gear", action: action)
    }
}

// MARK: - Previews

private extension ToolbarButtonView {
    static func makePreview(colorScheme: ColorScheme) -> some View {
        VStack(spacing: 20) {
            ToolbarButtonView.add {}
            ToolbarButtonView.edit {}
            ToolbarButtonView.save {}
            ToolbarButtonView.delete {}
            ToolbarButtonView.close {}
            ToolbarButtonView.settings {}
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview("Light") {
    ToolbarButtonView.makePreview(colorScheme: .light)
}

#Preview("dark") {
    ToolbarButtonView.makePreview(colorScheme: .dark)
}
