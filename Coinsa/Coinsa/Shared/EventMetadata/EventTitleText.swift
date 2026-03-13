//
//  EventTitleText.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventTitleText: View {
    // MARK: - Stored Properties
    
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        Text(title).font(.title2).fontWeight(.semibold)
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    EventTitleText(title: "Заголовок события").preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    EventTitleText(title: "Event title").preferredColorScheme(.light)
}
