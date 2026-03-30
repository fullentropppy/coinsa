//
//  TitleText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct TitleText: View {
    // MARK: - Stored Properties
    
    private let title: String
    
    // MARK: - Initialization
    
    init(_ title: String) {
        self.title = title
    }
    
    // MARK: - Body
    
    var body: some View {
        Text(title).fontWeight(.semibold)
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    TitleText("Заголовок").preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    TitleText("Title").preferredColorScheme(.light)
}
