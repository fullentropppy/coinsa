//
//  GroupHeader.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 10.04.2026.
//

import SwiftUI

/// Заголовок для секции группы, отображающий иконку, основной текст и опционально подтекст.
struct GroupHeader: View {
    // MARK: - Свойства
    
    let icon: String
    let title: LocalizedStringResource
    let itemCount: Int?
    
    // MARK: - Тело View
    
    /// Создает заголовок секции группы.
    /// - Parameters:
    ///   - icon: Название системной иконки.
    ///   - title: Заголовок.
    ///   - itemCount: Количество элементов в группе (опционально).
    init(icon: String, title: LocalizedStringResource, itemCount: Int? = nil) {
        self.icon = icon
        self.title = title
        self.itemCount = itemCount
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center, spacing: 4) {
                if let itemCount {
                    Text(String(itemCount))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.windowBackground)
                        .padding(.horizontal, 4)
                        .frame(minWidth: 18)
                        .frame(height: 18)
                        .background(.gray.opacity(1), in: .capsule)
                }
                
                Image(systemName: icon)
                    .imageScale(.small)
                    .fontWeight(.semibold)
                Text(title)
                    .fontWeight(.semibold)
            }
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Превью

#Preview {
    GroupHeader(icon: Location.primaryIcon, title: .tripLocations, itemCount: 4)
}
