//
//  LocationRowView.swift
//  Coinsa
//
//  Created by Daniil Gritsenko on 03.03.2026.
//

import SwiftUI

/// Строка для отображения локации в списке.
struct LocationRowView: View {
    // MARK: - Свойства
    
    let location: Location
    
    // MARK: - Инициализация
    
    /// Создает строку для отображения локации.
    /// - Parameter location: Локация для отображения.
    init(_ location: Location) {
        self.location = location
    }
    
    // MARK: - Тело View
    
    var body: some View {
        VStack(alignment: .leading, spacing: ViewLayout.Row.contentSpacing) {
            upperStack
            lowerStack
        }
    }
    
    // MARK: - Компоненты
    
    private var upperStack: some View {
        HStack(spacing: ViewLayout.Row.metadataSpacing) {
            location.status.makeDot()
            Text(location.name).fontWeight(.semibold)
        }
    }
    
    private var lowerStack: some View {
        HStack(spacing: ViewLayout.Row.metadataSpacing) {
            DateLabel.secondarySmall(from: location.startPlainDate, to: location.endPlainDate)
            Spacer()
            CountLabel.secondarySmall(location.expensesCount, icon: Expense.primaryIcon)
            DotDivider.secondarySmall()
            CountLabel.daysSecondarySmall(location.totalDays)
        }
    }
}

// MARK: - Превью

#Preview {
    List {
        LocationRowView(PreviewGenerator.makeExampleLocation(includeExpenses: true))
    }
}
