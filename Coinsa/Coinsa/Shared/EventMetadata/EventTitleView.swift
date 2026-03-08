//
//  EventIntervalView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 06.03.2026.
//

import SwiftUI

struct EventTitleView: View {
    // MARK: - Stored Properties
    
    let title: String
    
    // MARK: - Body
    
    var body: some View {
        Text(title).font(.title2).fontWeight(.semibold)
    }
}

// MARK: - Previews

#Preview("Light - RU") {
    EventTitleView(title: "Заголовок").preferredColorScheme(.light)
}

#Preview("Dark - EN") {
    EventTitleView(title: "Title").preferredColorScheme(.light)
}
